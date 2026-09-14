import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchedProvider extends ChangeNotifier {
  WatchedProvider() {
    _loadWatched();
  }

  static const String _storageKey = 'watched_episode_ids';

  final Set<int> _watchedEpisodeIds = <int>{};

  Set<int> get watchedEpisodeIds => _watchedEpisodeIds;

  bool isWatched(int episodeId) {
    return _watchedEpisodeIds.contains(episodeId);
  }

  Future<void> toggleWatched(int episodeId) async {
    if (_watchedEpisodeIds.contains(episodeId)) {
      _watchedEpisodeIds.remove(episodeId);
    } else {
      _watchedEpisodeIds.add(episodeId);
    }

    notifyListeners();
    await _saveWatched();
  }

  Future<void> _loadWatched() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> values = prefs.getStringList(_storageKey) ?? <String>[];

    _watchedEpisodeIds
      ..clear()
      ..addAll(values.map(int.parse));

    notifyListeners();
  }

  Future<void> _saveWatched() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _watchedEpisodeIds.map((int id) => id.toString()).toList(),
    );
  }
}
