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
      _readEnv('API_BASE_URL') ?? AppConstants.defaultApiBaseUrl;

    static String get firebaseApiKey => _readEnv('FIREBASE_API_KEY') ?? '';
    static String get firebaseAppId => _readEnv('FIREBASE_APP_ID') ?? '';
    static String get firebaseProjectId => _readEnv('FIREBASE_PROJECT_ID') ?? '';
    static String get firebaseMessagingSenderId =>
      _readEnv('FIREBASE_MESSAGING_SENDER_ID') ?? '';
    static String get firebaseStorageBucket =>
      _readEnv('FIREBASE_STORAGE_BUCKET') ?? '';
    static String get firebaseAuthDomain => _readEnv('FIREBASE_AUTH_DOMAIN') ?? '';
    static String get firebaseMeasurementId =>
      _readEnv('FIREBASE_MEASUREMENT_ID') ?? '';

  static bool get isFirebaseConfigured =>
      firebaseApiKey.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      firebaseProjectId.isNotEmpty;

  static String? _readEnv(String key) {
    try {
      return dotenv.maybeGet(key);
    } catch (_) {
      return null;
    }
  }
}
