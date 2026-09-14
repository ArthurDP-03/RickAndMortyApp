import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/character_model.dart';
import '../models/episode_model.dart';

class EpisodeApiService {
  static const String _baseUrl = 'https://rickandmortyapi.com/api';

  Future<List<EpisodeModel>> getEpisodes({int page = 1}) async {
    final Uri uri = Uri.parse('$_baseUrl/episode?page=$page');
    return _fetchEpisodeList(uri);
  }

  Future<List<EpisodeModel>> searchEpisodesByName(String name) async {
    final Uri uri = Uri.parse('$_baseUrl/episode/?name=$name');
    return _fetchEpisodeList(uri);
  }

  Future<List<CharacterModel>> getCharactersByUrls(List<String> characterUrls) async {
    if (characterUrls.isEmpty) {
      return <CharacterModel>[];
    }

    // Extrair IDs das URLs (ex: https://rickandmortyapi.com/api/character/1 -> 1)
    final List<String> ids = characterUrls
        .map((String url) => url.split('/').where((String s) => s.isNotEmpty).last)
        .where((String id) => int.tryParse(id) != null)
        .toList();

    if (ids.isEmpty) {
      return <CharacterModel>[];
    }

    // A API do Rick and Morty permite buscar múltiplos IDs com /character/1,2,3
    final String idsParam = ids.join(',');
    final Uri uri = Uri.parse('$_baseUrl/character/$idsParam');
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      if (data is List) {
        return data
            .map((dynamic item) =>
                CharacterModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic>) {
        return <CharacterModel>[CharacterModel.fromJson(data)];
      }
    }

    return <CharacterModel>[];
  }

  Future<List<EpisodeModel>> _fetchEpisodeList(Uri uri) async {
    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> results = data['results'] as List<dynamic>;

      return results
          .map((dynamic item) =>
              EpisodeModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (response.statusCode == 404) {
      return <EpisodeModel>[];
    }

    throw Exception('Erro ao buscar episodios: ${response.statusCode}');
  }
}
