import 'package:flutter/foundation.dart';

import '../models/episode_model.dart';
import '../services/episode_api_service.dart';

class EpisodeProvider extends ChangeNotifier {
  EpisodeProvider({EpisodeApiService? apiService})
      : _apiService = apiService ?? EpisodeApiService();

  final EpisodeApiService _apiService;

  final List<EpisodeModel> _episodes = <EpisodeModel>[];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  String _activeQuery = '';

  List<EpisodeModel> get episodes => List<EpisodeModel>.unmodifiable(_episodes);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> fetchInitialEpisodes() async {
    _currentPage = 1;
    _hasMore = true;
    _activeQuery = '';
    _episodes.clear();
    await _fetchPage(resetList: true);
  }

  Future<void> loadMoreEpisodes() async {
    if (_isLoading || !_hasMore || _activeQuery.isNotEmpty) {
      return;
    }

    _currentPage += 1;
    await _fetchPage(resetList: false);
  }

  Future<void> searchByName(String name) async {
    final String normalized = name.trim();

    _isLoading = true;
    _errorMessage = null;
    _activeQuery = normalized;
    notifyListeners();

    try {
      if (normalized.isEmpty) {
        await fetchInitialEpisodes();
        return;
      }

      final List<EpisodeModel> result =
          await _apiService.searchEpisodesByName(normalized);
      _episodes
        ..clear()
        ..addAll(result);
      _hasMore = false;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchPage({required bool resetList}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<EpisodeModel> result =
          await _apiService.getEpisodes(page: _currentPage);

      if (resetList) {
        _episodes
          ..clear()
          ..addAll(result);
      } else {
        _episodes.addAll(result);
      }

      if (result.isEmpty) {
        _hasMore = false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (!resetList) {
        _currentPage -= 1;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
