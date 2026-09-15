import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rick_and_morty_app/config/constants.dart';
import 'package:rick_and_morty_app/models/episode_model.dart';
import 'package:rick_and_morty_app/models/user_model.dart';

/// Serviço de Armazenamento Local usando SharedPreferences
class LocalStorageService {
  static SharedPreferences? _preferences;

  static Future<SharedPreferences> get _instance async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  // --- FAVORITOS ---
  static Future<List<Episode>> getFavorites() async {
    final prefs = await _instance;
    final jsonList = prefs.getStringList(AppConstants.storageKeyFavorites) ?? [];
    return jsonList
        .map((str) => Episode.fromJson(json.decode(str) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveFavorites(List<Episode> episodes) async {
    final prefs = await _instance;
    final jsonList = episodes.map((ep) => json.encode(ep.toJson())).toList();
    await prefs.setStringList(AppConstants.storageKeyFavorites, jsonList);
  }

  // --- ASSISTIDOS / CONSUMIDOS ---
  static Future<List<Episode>> getWatched() async {
    final prefs = await _instance;
    final jsonList = prefs.getStringList(AppConstants.storageKeyWatched) ?? [];
    return jsonList
        .map((str) => Episode.fromJson(json.decode(str) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveWatched(List<Episode> episodes) async {
    final prefs = await _instance;
    final jsonList = episodes.map((ep) => json.encode(ep.toJson())).toList();
    await prefs.setStringList(AppConstants.storageKeyWatched, jsonList);
  }

  // --- SESSÃO E USUÁRIO ---
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await _instance;
    final userJson = prefs.getString(AppConstants.storageKeyUser);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        return UserModel.fromJson(json.decode(userJson) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<void> saveCurrentUser(UserModel user) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.storageKeyUser, json.encode(user.toJson()));
    await prefs.setBool(AppConstants.storageKeyIsLoggedIn, true);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.storageKeyIsLoggedIn) ?? false;
  }

  static Future<void> clearSession() async {
    final prefs = await _instance;
    await prefs.remove(AppConstants.storageKeyUser);
    await prefs.setBool(AppConstants.storageKeyIsLoggedIn, false);
  }

  // --- BASE DE USUÁRIOS REGISTRADOS LOCALMENTE ---
  static Future<Map<String, dynamic>> getRegisteredAccounts() async {
    final prefs = await _instance;
    final raw = prefs.getString(AppConstants.storageKeyUsersList);
    if (raw == null || raw.isEmpty) return {};
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveAccount(
    String email,
    String password,
    UserModel user,
  ) async {
    final prefs = await _instance;
    final accounts = await getRegisteredAccounts();
    accounts[email.toLowerCase().trim()] = {
      'password': password,
      'user': user.toJson(),
    };
    await prefs.setString(AppConstants.storageKeyUsersList, json.encode(accounts));
  }
}
