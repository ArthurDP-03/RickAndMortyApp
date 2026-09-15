/// Modelo de Personagem da API Rick and Morty
class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String image;
  final String url;
  final String originName;
  final String locationName;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.image,
    required this.url,
    required this.originName,
    required this.locationName,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? 'Desconhecido',
      status: json['status'] as String? ?? 'Unknown',
      species: json['species'] as String? ?? 'Desconhecida',
      type: json['type'] as String? ?? '',
      gender: json['gender'] as String? ?? 'Desconhecido',
      image: json['image'] as String? ?? '',
      url: json['url'] as String? ?? '',
      originName: json['origin'] is Map
          ? (json['origin']['name'] as String? ?? 'Desconhecida')
          : 'Desconhecida',
      locationName: json['location'] is Map
          ? (json['location']['name'] as String? ?? 'Desconhecida')
          : 'Desconhecida',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'image': image,
      'url': url,
      'origin': {'name': originName},
      'location': {'name': locationName},
    };
  }
}
