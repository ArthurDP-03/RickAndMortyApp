import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider() {
    _loadFavorites();
  }

  static const String _storageKey = 'favorite_episode_ids';

  final Set<int> _favoriteEpisodeIds = <int>{};

  Set<int> get favoriteEpisodeIds => _favoriteEpisodeIds;

  bool isFavorite(int episodeId) {
    return _favoriteEpisodeIds.contains(episodeId);
  }

  Future<void> toggleFavorite(int episodeId) async {
    if (_favoriteEpisodeIds.contains(episodeId)) {
      _favoriteEpisodeIds.remove(episodeId);
    } else {
      _favoriteEpisodeIds.add(episodeId);
    }

    notifyListeners();
    await _saveFavorites();
  }

  Future<void> _loadFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> values = prefs.getStringList(_storageKey) ?? <String>[];

    _favoriteEpisodeIds
      ..clear()
      ..addAll(values.map(int.parse));

    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _favoriteEpisodeIds.map((int id) => id.toString()).toList(),
    );
  }
}
