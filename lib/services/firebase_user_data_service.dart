import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rick_and_morty_app/models/episode_model.dart';
import 'package:rick_and_morty_app/models/user_model.dart';

/// Camada de persistencia em nuvem por usuario no Firestore.
class FirebaseUserDataService {
  FirebaseUserDataService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('usuarios');

  static const String _fieldUid = 'uid';
  static const String _fieldName = 'name';
  static const String _fieldNome = 'nome';
  static const String _fieldEmail = 'email';
  static const String _fieldBirthDate = 'birthDate';
  static const String _fieldPhotoUrl = 'photoUrl';
  static const String _fieldFavorites = 'favorites';
  static const String _fieldFavoritos = 'favoritos';
  static const String _fieldWatched = 'watched';
  static const String _fieldAssistidos = 'assistidos';
  static const String _fieldUpdatedAt = 'updatedAt';

  Future<void> upsertUserProfile(UserModel user) async {
    await _users.doc(user.id).set({
      _fieldUid: user.id,
      _fieldName: user.name,
      _fieldNome: user.name,
      _fieldEmail: user.email,
      _fieldBirthDate: user.birthDate,
      _fieldPhotoUrl: user.photoUrl,
      _fieldUpdatedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data() ?? <String, dynamic>{};
    return UserModel(
      id: uid,
      name:
          (data[_fieldName] as String?) ?? (data[_fieldNome] as String?) ?? '',
      email: (data[_fieldEmail] as String?) ?? '',
      birthDate: data[_fieldBirthDate] as String?,
      photoUrl: data[_fieldPhotoUrl] as String?,
    );
  }

  Future<List<Episode>> getFavorites(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists) {
      return <Episode>[];
    }

    final data = snapshot.data() ?? <String, dynamic>{};
    return _episodesFromData(
      data,
      primaryKey: _fieldFavorites,
      fallbackKey: _fieldFavoritos,
    );
  }

  Future<void> saveFavorites(String uid, List<Episode> favorites) async {
    final serialized = favorites.map((episode) => episode.toJson()).toList();
    await _users.doc(uid).set({
      _fieldFavorites: serialized,
      _fieldFavoritos: serialized,
      _fieldUpdatedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Episode>> getWatched(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists) {
      return <Episode>[];
    }

    final data = snapshot.data() ?? <String, dynamic>{};
    return _episodesFromData(
      data,
      primaryKey: _fieldWatched,
      fallbackKey: _fieldAssistidos,
    );
  }

  Future<void> saveWatched(String uid, List<Episode> watched) async {
    final serialized = watched.map((episode) => episode.toJson()).toList();
    await _users.doc(uid).set({
      _fieldWatched: serialized,
      _fieldAssistidos: serialized,
      _fieldUpdatedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<Episode>> watchFavorites(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data() ?? <String, dynamic>{};
      return _episodesFromData(
        data,
        primaryKey: _fieldFavorites,
        fallbackKey: _fieldFavoritos,
      );
    });
  }

  Stream<List<Episode>> watchWatched(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data() ?? <String, dynamic>{};
      return _episodesFromData(
        data,
        primaryKey: _fieldWatched,
        fallbackKey: _fieldAssistidos,
      );
    });
  }

  List<Episode> _episodesFromData(
    Map<String, dynamic> data, {
    required String primaryKey,
    required String fallbackKey,
  }) {
    final rawList = (data[primaryKey] as List<dynamic>?) ??
        (data[fallbackKey] as List<dynamic>?) ??
        <dynamic>[];

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(Episode.fromJson)
        .toList();
  }
}
