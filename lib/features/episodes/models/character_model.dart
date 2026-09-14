class CharacterModel {
  const CharacterModel({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.image,
    required this.url,
  });

  final int id;
  final String name;
  final String status;
  final String species;
  final String image;
  final String url;

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Desconhecido',
      status: json['status'] as String? ?? 'Desconhecido',
      species: json['species'] as String? ?? '',
      image: json['image'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}
