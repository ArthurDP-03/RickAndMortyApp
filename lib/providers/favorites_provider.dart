import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/models/episode_model.dart';
import 'package:rick_and_morty_app/models/user_model.dart';
import 'package:rick_and_morty_app/services/firebase_user_data_service.dart';
import 'package:rick_and_morty_app/services/local_storage_service.dart';

/// Provedor Global de Episódios Favoritos (RF04, RF05, RF06)
class FavoritesProvider extends ChangeNotifier {
  FirebaseUserDataService? _firebaseUserDataService;
  StreamSubscription<List<Episode>>? _favoritesSubscription;
  List<Episode> _favorites = [];
  UserModel? _currentUser;
  bool _isLoading = false;

  FavoritesProvider({
    this._firebaseUserDataService,
    bool autoLoad = true,
  }) {
    if (autoLoad) {
      loadFavorites();
    }
  }

  bool get _canUseCloud =>
      Firebase.apps.isNotEmpty && _currentUser != null;

  FirebaseUserDataService get _cloudService =>
      _firebaseUserDataService ??= FirebaseUserDataService();

  void setCurrentUser(UserModel? user) {
    final previousId = _currentUser?.id;
    final nextId = user?.id;
    if (previousId == nextId) return;
    _favoritesSubscription?.cancel();
    _favoritesSubscription = null;
    _currentUser = user;
    _listenCloudFavorites();
    loadFavorites();
  }

  /// Retorna lista de favoritos ordenada crescentemente por temporada e episódio
  List<Episode> get favorites {
    final sortedList = List<Episode>.from(_favorites);
    sortedList.sort((a, b) {
      if (a.seasonNumber != b.seasonNumber) {
        return a.seasonNumber.compareTo(b.seasonNumber);
      }
      return a.episodeNumber.compareTo(b.episodeNumber);
    });
    return sortedList;
  }

  int get count => _favorites.length;
  bool get isLoading => _isLoading;

  /// Carrega os favoritos do armazenamento local
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    try {
      final localFavorites = await LocalStorageService.getFavorites();

      if (_canUseCloud) {
        final userId = _currentUser!.id;
        final cloudFavorites = await _cloudService.getFavorites(userId);

        if (cloudFavorites.isEmpty && localFavorites.isNotEmpty) {
          // Migra dados locais para nuvem no primeiro login para esse usuario.
          await _cloudService.saveFavorites(userId, localFavorites);
          _favorites = localFavorites;
        } else {
          _favorites = cloudFavorites;
          await LocalStorageService.saveFavorites(cloudFavorites);
        }
      } else {
        _favorites = localFavorites;
      }
    } catch (_) {
      _favorites = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verifica se um episódio está favoritado
  bool isFavorite(int episodeId) {
    return _favorites.any((ep) => ep.id == episodeId);
  }

  /// Alterna o estado de favorito de um episódio
  Future<void> toggleFavorite(Episode episode) async {
    final exists = isFavorite(episode.id);
    if (exists) {
      _favorites.removeWhere((ep) => ep.id == episode.id);
    } else {
      _favorites.add(episode);
    }
    notifyListeners();
    await LocalStorageService.saveFavorites(_favorites);

    if (_canUseCloud) {
      await _cloudService.saveFavorites(_currentUser!.id, _favorites);
    }
  }

  void _listenCloudFavorites() {
    if (!_canUseCloud) {
      return;
    }

    final userId = _currentUser!.id;
    _favoritesSubscription = _cloudService.watchFavorites(userId).listen((items) async {
      _favorites = items;
      await LocalStorageService.saveFavorites(items);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    super.dispose();
  }
}
