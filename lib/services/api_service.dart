import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rick_and_morty_app/config/env_config.dart';
import 'package:rick_and_morty_app/models/api_response.dart';
import 'package:rick_and_morty_app/models/character_model.dart';
import 'package:rick_and_morty_app/models/episode_model.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  String get _baseUrl => EnvConfig.apiBaseUrl;

  Future<ApiResponse<Episode>> getEpisodes({
    int page = 1,
    String? name,
    String? episode,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
    };

    if (name != null && name.trim().isNotEmpty) {
      queryParameters['name'] = name.trim();
    }
    if (episode != null && episode.trim().isNotEmpty) {
      queryParameters['episode'] = episode.trim();
    }

    final uri = Uri.parse('$_baseUrl/episode').replace(
      queryParameters: queryParameters,
    );

    try {
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 12),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final info = ApiPageInfo.fromJson(data['info'] ?? {});
        final results = (data['results'] as List<dynamic>? ?? [])
            .map((item) => Episode.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse(info: info, results: results);
      } else if (response.statusCode == 404) {
        return ApiResponse(
          info: ApiPageInfo(count: 0, pages: 0),
          results: [],
        );
      } else {
        throw Exception(
          'Falha ao carregar episódios da API (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão com o servidor: $e');
    }
  }

  Future<Episode> getEpisodeById(int id) async {
    final uri = Uri.parse('$_baseUrl/episode/$id');
    try {
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Episode.fromJson(data);
      } else {
        throw Exception(
          'Episódio #$id não encontrado (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro ao buscar episódio: $e');
    }
  }

  Future<List<Character>> getCharactersByUrls(List<String> urls) async {
    if (urls.isEmpty) return [];

    final ids = urls
        .map((url) => RegExp(r'/(\d+)$').firstMatch(url)?.group(1))
        .whereType<String>()
        .take(20)
        .toList();

    if (ids.isEmpty) return [];

    final joinedIds = ids.join(',');
    final uri = Uri.parse('$_baseUrl/character/$joinedIds');

    try {
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 12),
          );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded
              .map((item) => Character.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (decoded is Map<String, dynamic>) {
          return [Character.fromJson(decoded)];
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
