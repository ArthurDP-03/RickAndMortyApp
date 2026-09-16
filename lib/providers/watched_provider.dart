import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/models/episode_model.dart';
import 'package:rick_and_morty_app/models/user_model.dart';
import 'package:rick_and_morty_app/services/firebase_user_data_service.dart';
import 'package:rick_and_morty_app/services/local_storage_service.dart';

/// Provedor Global de Episódios Assistidos / Consumidos (RF06, RF07)
class WatchedProvider extends ChangeNotifier {
  FirebaseUserDataService? _firebaseUserDataService;
  StreamSubscription<List<Episode>>? _watchedSubscription;
  List<Episode> _watched = [];
  UserModel? _currentUser;
  bool _isLoading = false;

  WatchedProvider({
    this._firebaseUserDataService,
    bool autoLoad = true,
  }) {
    if (autoLoad) {
      loadWatched();
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
    _watchedSubscription?.cancel();
    _watchedSubscription = null;
    _currentUser = user;
    _listenCloudWatched();
    loadWatched();
  }

  /// Retorna lista de assistidos ordenada crescentemente por temporada e episódio
  List<Episode> get watched {
    final sortedList = List<Episode>.from(_watched);
    sortedList.sort((a, b) {
      if (a.seasonNumber != b.seasonNumber) {
        return a.seasonNumber.compareTo(b.seasonNumber);
      }
      return a.episodeNumber.compareTo(b.episodeNumber);
    });
    return sortedList;
  }

  int get count => _watched.length;
  bool get isLoading => _isLoading;

  /// Carrega a lista de assistidos do armazenamento local
  Future<void> loadWatched() async {
    _isLoading = true;
    notifyListeners();
    try {
      final localWatched = await LocalStorageService.getWatched();

      if (_canUseCloud) {
        final userId = _currentUser!.id;
        final cloudWatched = await _cloudService.getWatched(userId);

        if (cloudWatched.isEmpty && localWatched.isNotEmpty) {
          // Migra dados locais para nuvem no primeiro login para esse usuario.
          await _cloudService.saveWatched(userId, localWatched);
          _watched = localWatched;
        } else {
          _watched = cloudWatched;
          await LocalStorageService.saveWatched(cloudWatched);
        }
      } else {
        _watched = localWatched;
      }
    } catch (_) {
      _watched = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verifica se um episódio já foi assistido
  bool isWatched(int episodeId) {
    return _watched.any((ep) => ep.id == episodeId);
  }

  /// Alterna o status de assistido de um episódio
  Future<void> toggleWatched(Episode episode) async {
    final exists = isWatched(episode.id);
    if (exists) {
      _watched.removeWhere((ep) => ep.id == episode.id);
    } else {
      _watched.add(episode);
    }
    notifyListeners();
    await LocalStorageService.saveWatched(_watched);

    if (_canUseCloud) {
      await _cloudService.saveWatched(_currentUser!.id, _watched);
    }
  }

  void _listenCloudWatched() {
    if (!_canUseCloud) {
      return;
    }

    final userId = _currentUser!.id;
    _watchedSubscription = _cloudService.watchWatched(userId).listen((items) async {
      _watched = items;
      await LocalStorageService.saveWatched(items);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _watchedSubscription?.cancel();
    super.dispose();
  }
}
