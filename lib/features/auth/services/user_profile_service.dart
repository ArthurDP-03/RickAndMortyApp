import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  UserProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> ensureUserProfile(User user) async {
    final DocumentReference<Map<String, dynamic>> userRef =
        _firestore.collection('users').doc(user.uid);

    final DocumentSnapshot<Map<String, dynamic>> doc = await userRef.get();
    if (doc.exists) {
      return;
    }

    await userRef.set(<String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'favoriteEpisodes': <int>[],
      'watchedEpisodes': <int>[],
    });
  }
}
