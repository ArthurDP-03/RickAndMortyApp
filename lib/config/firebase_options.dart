import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:rick_and_morty_app/config/env_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não foi configurado para esta plataforma.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: EnvConfig.firebaseApiKey,
        appId: EnvConfig.firebaseAppId,
        messagingSenderId: EnvConfig.firebaseMessagingSenderId,
        projectId: EnvConfig.firebaseProjectId,
        authDomain: EnvConfig.firebaseAuthDomain.isNotEmpty
            ? EnvConfig.firebaseAuthDomain
            : null,
        storageBucket: EnvConfig.firebaseStorageBucket.isNotEmpty
            ? EnvConfig.firebaseStorageBucket
            : null,
        measurementId: EnvConfig.firebaseMeasurementId.isNotEmpty
            ? EnvConfig.firebaseMeasurementId
            : null,
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: EnvConfig.firebaseApiKey,
        appId: EnvConfig.firebaseAppId,
        messagingSenderId: EnvConfig.firebaseMessagingSenderId,
        projectId: EnvConfig.firebaseProjectId,
        storageBucket: EnvConfig.firebaseStorageBucket.isNotEmpty
            ? EnvConfig.firebaseStorageBucket
            : null,
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: EnvConfig.firebaseApiKey,
        appId: EnvConfig.firebaseAppId,
        messagingSenderId: EnvConfig.firebaseMessagingSenderId,
        projectId: EnvConfig.firebaseProjectId,
        storageBucket: EnvConfig.firebaseStorageBucket.isNotEmpty
            ? EnvConfig.firebaseStorageBucket
            : null,
        iosBundleId: 'com.example.rickAndMortyApp',
      );
}
