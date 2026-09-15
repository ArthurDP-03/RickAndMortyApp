/// Modelo de Usuário para autenticação e perfil
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? birthDate;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.birthDate,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      birthDate: json['birthDate'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birthDate': birthDate,
      'photoUrl': photoUrl,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? birthDate,
    String? photoUrl,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
