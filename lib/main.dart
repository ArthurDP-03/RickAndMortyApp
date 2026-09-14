import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Allows local app bootstrap before Firebase setup is completed.
    debugPrint('Firebase initialization skipped: $e');
  }

  runApp(const RMGuideApp());
}
