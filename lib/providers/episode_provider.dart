import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/models/episode_model.dart';
import 'package:rick_and_morty_app/services/api_service.dart';

/// Provedor Global do Catálogo de Episódios
class EpisodeProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Episode> _episodes = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;

  // Filtros ativos
  String _searchQuery = '';
  String _filterSeason = '';
  String _filterAirDate = '';

  EpisodeProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  List<Episode> get episodes {
    if (_filterAirDate.isEmpty) return _episodes;
    return _episodes
        .where((ep) =>
            ep.airDate.toLowerCase().contains(_filterAirDate.toLowerCase()))
        .toList();
  }

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMorePages => _currentPage < _totalPages;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get filterSeason => _filterSeason;
  String get filterAirDate => _filterAirDate;

  /// Busca inicial ou reset com filtros atuais
  Future<void> fetchEpisodes({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _episodes = [];
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getEpisodes(
        page: _currentPage,
        name: _searchQuery.isNotEmpty ? _searchQuery : null,
        episode: _filterSeason.isNotEmpty ? _filterSeason : null,
      );

      _episodes = response.results;
      _totalPages = response.info.pages;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega a próxima página (Carregar Mais - RF01)
  Future<void> loadMoreEpisodes() async {
    if (_isLoadingMore || !hasMorePages) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _apiService.getEpisodes(
        page: nextPage,
        name: _searchQuery.isNotEmpty ? _searchQuery : null,
        episode: _filterSeason.isNotEmpty ? _filterSeason : null,
      );

      _currentPage = nextPage;
      _totalPages = response.info.pages;

      // Evita duplicatas ao adicionar à lista
      final existingIds = _episodes.map((e) => e.id).toSet();
      for (final newEp in response.results) {
        if (!existingIds.contains(newEp.id)) {
          _episodes.add(newEp);
        }
      }
    } catch (e) {
      _errorMessage = 'Não foi possível carregar mais episódios.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Define a busca textual (RF08)
  Future<Episode?> searchDirectEpisode(String query) async {
    _searchQuery = query.trim();
    if (_searchQuery.isEmpty) {
      await fetchEpisodes(reset: true);
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getEpisodes(
        page: 1,
        name: _searchQuery,
      );

      _episodes = response.results;
      _totalPages = response.info.pages;
      _currentPage = 1;
      _isLoading = false;
      notifyListeners();

      if (response.results.isNotEmpty) {
        return response.results.first;
      }
      return null;
    } catch (e) {
      _errorMessage = 'Nenhum episódio encontrado para "$query".';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Aplica múltiplos filtros (Nome, Temporada/Código, Data de Lançamento)
  Future<void> applyFilters({
    String? name,
    String? season,
    String? airDate,
  }) async {
    _searchQuery = name ?? '';
    _filterSeason = season ?? '';
    _filterAirDate = airDate ?? '';
    await fetchEpisodes(reset: true);
  }

  /// Limpa todos os filtros
  Future<void> clearFilters() async {
    _searchQuery = '';
    _filterSeason = '';
    _filterAirDate = '';
    await fetchEpisodes(reset: true);
  }
}
