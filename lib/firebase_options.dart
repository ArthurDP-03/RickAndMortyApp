import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:rick_and_morty_app/config/env_config.dart';

class DefaultFirebaseOptions {
  static const String _webApiKey = 'AIzaSyDKSwkuvPt85MKovrg6XMwXGvdmMufQgVE';
  static const String _webAppId = '1:66954574456:web:7008b1f63ab360c89a4b8d';
  static const String _webProjectId = 'rickandmorty-5bdf9';
  static const String _webMessagingSenderId = '66954574456';
  static const String _webStorageBucket = 'rickandmorty-5bdf9.firebasestorage.app';
  static const String _webAuthDomain = 'rickandmorty-5bdf9.firebaseapp.com';
  static const String _webMeasurementId = 'G-BTDN5JR1LS';

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
          'DefaultFirebaseOptions nao foi configurado para esta plataforma.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
      apiKey: _webApiKey,
      appId: _webAppId,
      messagingSenderId: _webMessagingSenderId,
      projectId: _webProjectId,
      authDomain: _webAuthDomain,
      storageBucket: _webStorageBucket,
      measurementId: _webMeasurementId,
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: EnvConfig.firebaseApiKey,
        appId: EnvConfig.firebaseAppId,
        messagingSenderId: EnvConfig.firebaseMessagingSenderId,
        projectId: EnvConfig.firebaseProjectId,
        storageBucket: EnvConfig.firebaseStorageBucket,
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: EnvConfig.firebaseApiKey,
        appId: EnvConfig.firebaseAppId,
        messagingSenderId: EnvConfig.firebaseMessagingSenderId,
        projectId: EnvConfig.firebaseProjectId,
        storageBucket: EnvConfig.firebaseStorageBucket,
        iosBundleId: 'com.example.rickAndMortyApp',
      );
}
