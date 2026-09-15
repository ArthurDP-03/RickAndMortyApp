import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/models/episode_model.dart';
import 'package:rick_and_morty_app/services/local_storage_service.dart';

/// Provedor Global de Episódios Favoritos (RF04, RF05, RF06)
class FavoritesProvider extends ChangeNotifier {
  List<Episode> _favorites = [];
  bool _isLoading = false;

  FavoritesProvider() {
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
      _favorites = await LocalStorageService.getFavorites();
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
  }
}
