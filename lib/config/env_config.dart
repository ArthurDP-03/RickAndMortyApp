import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rick_and_morty_app/config/constants.dart';

/// Gerenciador de Configurações e Variáveis de Ambiente (.env)
class EnvConfig {
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // Caso o .env não exista ou falhe no carregamento, utiliza valores de fallback com segurança
    }
  }

  static String get apiBaseUrl =>
      dotenv.maybeGet('API_BASE_URL') ?? AppConstants.defaultApiBaseUrl;

  static String get firebaseApiKey => dotenv.maybeGet('FIREBASE_API_KEY') ?? '';
  static String get firebaseAppId => dotenv.maybeGet('FIREBASE_APP_ID') ?? '';
  static String get firebaseProjectId =>
      dotenv.maybeGet('FIREBASE_PROJECT_ID') ?? '';
  static String get firebaseMessagingSenderId =>
      dotenv.maybeGet('FIREBASE_MESSAGING_SENDER_ID') ?? '';
  static String get firebaseStorageBucket =>
      dotenv.maybeGet('FIREBASE_STORAGE_BUCKET') ?? '';
  static String get firebaseAuthDomain =>
      dotenv.maybeGet('FIREBASE_AUTH_DOMAIN') ?? '';

  static bool get isFirebaseConfigured =>
      firebaseApiKey.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      firebaseProjectId.isNotEmpty;
}
