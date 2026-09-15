import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/models/episode_model.dart';
import 'package:rick_and_morty_app/services/local_storage_service.dart';

/// Provedor Global de Episódios Assistidos / Consumidos (RF06, RF07)
class WatchedProvider extends ChangeNotifier {
  List<Episode> _watched = [];
  bool _isLoading = false;

  WatchedProvider() {
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
      _watched = await LocalStorageService.getWatched();
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
  }
}
