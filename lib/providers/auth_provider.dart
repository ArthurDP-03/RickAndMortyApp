import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/models/user_model.dart';
import 'package:rick_and_morty_app/services/auth_service.dart';

/// Provedor Global de Autenticação e Sessão de Usuário
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Inicializa a sessão ao abrir o app
  Future<void> checkCurrentSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Realiza login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authService.login(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Realiza login com Google
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authService.signInWithGoogle();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Realiza cadastro
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? birthDate,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authService.register(
        name: name,
        email: email,
        password: password,
        birthDate: birthDate,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Atualiza o perfil do usuário atual
  Future<bool> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    try {
      _currentUser = await _authService.updateProfile(updatedUser);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Desconecta a conta
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
