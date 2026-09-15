/// Modelo de Episódio da API Rick and Morty
class Episode {
  final int id;
  final String name;
  final String airDate;
  final String episode;
  final List<String> characters;
  final String url;
  final String created;

  Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episode,
    required this.characters,
    required this.url,
    required this.created,
  });

  /// Identificador formatado da Temporada (ex: "S01" -> 1)
  int get seasonNumber {
    final match = RegExp(r'S(\d+)E(\d+)').firstMatch(episode);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '1') ?? 1;
    }
    return 1;
  }

  /// Identificador formatado do Episódio (ex: "E09" -> 9)
  int get episodeNumber {
    final match = RegExp(r'S(\d+)E(\d+)').firstMatch(episode);
    if (match != null) {
      return int.tryParse(match.group(2) ?? '1') ?? 1;
    }
    return id;
  }

  /// Thumbnail representativa baseada no primeiro personagem ou fallback
  String get thumbnailPlaceholder {
    if (characters.isNotEmpty) {
      final match = RegExp(r'/(\d+)$').firstMatch(characters.first);
      if (match != null) {
        return 'https://rickandmortyapi.com/api/character/avatar/${match.group(1)}.jpeg';
      }
    }
    return 'https://rickandmortyapi.com/api/character/avatar/1.jpeg';
  }

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? 'Episódio Desconhecido',
      airDate: json['air_date'] as String? ?? 'Data Desconhecida',
      episode: json['episode'] as String? ?? 'S00E00',
      characters: (json['characters'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      url: json['url'] as String? ?? '',
      created: json['created'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'air_date': airDate,
      'episode': episode,
      'characters': characters,
      'url': url,
      'created': created,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Episode &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
