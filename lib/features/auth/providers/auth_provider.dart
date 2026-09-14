import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/user_profile_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService, UserProfileService? userProfileService})
      : _authService = authService ?? AuthService(),
        _userProfileService = userProfileService ?? UserProfileService() {
    _user = _authService.currentUser;
    if (_user != null) {
      unawaited(_userProfileService.ensureUserProfile(_user!));
    }
    _authSubscription = _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        unawaited(_userProfileService.ensureUserProfile(user));
      }
      notifyListeners();
    });
  }

  final AuthService _authService;
  final UserProfileService _userProfileService;
  StreamSubscription<User?>? _authSubscription;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.signIn(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Falha no login.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.signUp(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Falha no cadastro.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.signOut();
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Falha ao sair.';
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
