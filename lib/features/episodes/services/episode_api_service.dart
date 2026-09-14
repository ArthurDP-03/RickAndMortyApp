import 'dart:convert';

import 'package:http/http.dart' as http;

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
