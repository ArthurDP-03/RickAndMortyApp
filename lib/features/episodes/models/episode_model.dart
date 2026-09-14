class EpisodeModel {
  EpisodeModel({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episodeCode,
    required this.characters,
    required this.url,
    required this.created,
  });

  final int id;
  final String name;
  final String airDate;
  final String episodeCode;
  final List<String> characters;
  final String url;
  final DateTime created;

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      airDate: json['air_date'] as String,
      episodeCode: json['episode'] as String,
      characters: List<String>.from(json['characters'] as List<dynamic>),
      url: json['url'] as String,
      created: DateTime.parse(json['created'] as String),
    );
  }
}
