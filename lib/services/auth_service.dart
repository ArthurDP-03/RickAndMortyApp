import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rick_and_morty_app/models/user_model.dart';
import 'package:rick_and_morty_app/services/firebase_user_data_service.dart';
import 'package:rick_and_morty_app/services/local_storage_service.dart';

/// Serviço Unificado de Autenticação (Local + Suporte a Firebase)
class AuthService {
  FirebaseAuth? _firebaseAuth;
  FirebaseUserDataService? _firebaseUserDataService;

  AuthService({
    this._firebaseAuth,
    this._firebaseUserDataService,
  });

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  FirebaseAuth get _auth => _firebaseAuth ??= FirebaseAuth.instance;

  FirebaseUserDataService get _userDataService =>
      _firebaseUserDataService ??= FirebaseUserDataService();

  GoogleSignIn get _googleSignIn => GoogleSignIn(scopes: ['email']);

  /// Realiza login de usuário
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.toLowerCase().trim();

    // Se Firebase estiver configurado no .env, usa autenticacao real do Firebase Auth.
    if (_isFirebaseReady) {
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        final firebaseUser = credential.user;
        if (firebaseUser == null) {
          throw Exception('Nao foi possivel autenticar no Firebase.');
        }

        final profile = await _userDataService.getUserProfile(
          firebaseUser.uid,
        );

        final nameFromEmail = _nameFromEmail(cleanEmail);
        final user = profile ??
            UserModel(
              id: firebaseUser.uid,
              name: firebaseUser.displayName?.trim().isNotEmpty == true
                  ? firebaseUser.displayName!.trim()
                  : nameFromEmail,
              email: firebaseUser.email ?? cleanEmail,
            );

        await _userDataService.upsertUserProfile(user);
        await LocalStorageService.saveCurrentUser(user);
        return user;
      } on FirebaseAuthException catch (e) {
        throw Exception(_mapFirebaseAuthError(e));
      }
    }

    // Autenticação Local persistente
    final accounts = await LocalStorageService.getRegisteredAccounts();
    if (accounts.containsKey(cleanEmail)) {
      final accountData = accounts[cleanEmail] as Map<String, dynamic>;
      if (accountData['password'] == password) {
        final user = UserModel.fromJson(
          accountData['user'] as Map<String, dynamic>,
        );
        await LocalStorageService.saveCurrentUser(user);
        return user;
      } else {
        throw Exception('Senha incorreta.');
      }
    }

    throw Exception('Conta nao encontrada. Faca cadastro antes de entrar.');
  }

  /// Realiza login com Google
  Future<UserModel> signInWithGoogle() async {
    if (!_isFirebaseReady) {
      throw Exception('Firebase nao inicializado.');
    }

    try {
      if (kIsWeb) {
        final userCredential = await _auth.signInWithPopup(
          GoogleAuthProvider(),
        );

        final firebaseUser = userCredential.user;
        if (firebaseUser == null) {
          throw Exception('Nao foi possivel autenticar com Google.');
        }

        final displayName = _resolveDisplayName(
          firebaseUser.displayName,
          null,
          firebaseUser.email,
          null,
        );
        final email = _resolveEmail(firebaseUser.email, null);

        final user = UserModel(
          id: firebaseUser.uid,
          name: displayName,
          email: email,
          photoUrl: firebaseUser.photoURL,
        );

        await firebaseUser.updateDisplayName(displayName);
        await _userDataService.upsertUserProfile(user);
        await LocalStorageService.saveCurrentUser(user);
        return user;
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Login com Google cancelado.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Nao foi possivel autenticar com Google.');
      }

      final displayName = _resolveDisplayName(
        firebaseUser.displayName,
        googleUser.displayName,
        firebaseUser.email,
        googleUser.email,
      );
      final email = _resolveEmail(firebaseUser.email, googleUser.email);
      final photoUrl = firebaseUser.photoURL ?? googleUser.photoUrl;

      final user = UserModel(
        id: firebaseUser.uid,
        name: displayName,
        email: email,
        photoUrl: photoUrl,
      );

      await firebaseUser.updateDisplayName(displayName);
      await _userDataService.upsertUserProfile(user);
      await LocalStorageService.saveCurrentUser(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Registra um novo usuário
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? birthDate,
  }) async {
    final cleanEmail = email.toLowerCase().trim();

    if (name.trim().isEmpty) {
      throw Exception('Por favor, informe seu nome.');
    }
    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      throw Exception('Por favor, informe um e-mail válido.');
    }
    if (password.length < 6) {
      throw Exception('A senha deve ter pelo menos 6 caracteres.');
    }

    if (_isFirebaseReady) {
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        final firebaseUser = credential.user;
        if (firebaseUser == null) {
          throw Exception('Nao foi possivel criar a conta no Firebase.');
        }

        await firebaseUser.updateDisplayName(name.trim());

        final user = UserModel(
          id: firebaseUser.uid,
          name: name.trim(),
          email: firebaseUser.email ?? cleanEmail,
          birthDate: birthDate,
        );

        await _userDataService.upsertUserProfile(user);
        await LocalStorageService.saveCurrentUser(user);
        return user;
      } on FirebaseAuthException catch (e) {
        throw Exception(_mapFirebaseAuthError(e));
      }
    }

    final accounts = await LocalStorageService.getRegisteredAccounts();
    if (accounts.containsKey(cleanEmail)) {
      throw Exception('Este e-mail ja esta cadastrado. Faca login.');
    }

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: cleanEmail,
      birthDate: birthDate,
    );

    await LocalStorageService.saveAccount(cleanEmail, password, user);
    await LocalStorageService.saveCurrentUser(user);
    return user;
  }

  /// Atualiza o perfil do usuário
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    if (_isFirebaseReady) {
      await _userDataService.upsertUserProfile(updatedUser);
      await _auth.currentUser?.updateDisplayName(updatedUser.name);
    }
    await LocalStorageService.saveCurrentUser(updatedUser);
    return updatedUser;
  }

  /// Desconecta o usuário
  Future<void> logout() async {
    if (_isFirebaseReady) {
      await _auth.signOut();
    }
    await LocalStorageService.clearSession();
  }

  /// Recupera o usuário atualmente logado
  Future<UserModel?> getCurrentUser() async {
    if (_isFirebaseReady) {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return null;
      }

      final profile = await _userDataService.getUserProfile(
        firebaseUser.uid,
      );

      final user = profile ??
          UserModel(
            id: firebaseUser.uid,
            name: firebaseUser.displayName?.trim().isNotEmpty == true
                ? firebaseUser.displayName!.trim()
                : _nameFromEmail(firebaseUser.email ?? ''),
            email: firebaseUser.email ?? '',
          );

      await _userDataService.upsertUserProfile(user);
      await LocalStorageService.saveCurrentUser(user);
      return user;
    }

    return await LocalStorageService.getCurrentUser();
  }

  String _nameFromEmail(String email) {
    final base = email.split('@').first.trim();
    if (base.isEmpty) {
      return 'Viajante Dimensional';
    }
    return '${base[0].toUpperCase()}${base.substring(1)}';
  }

  String _resolveDisplayName(
    String? firebaseDisplayName,
    String? googleDisplayName,
    String? firebaseEmail,
    String? googleEmail,
  ) {
    final firebaseName = firebaseDisplayName?.trim();
    if (firebaseName != null && firebaseName.isNotEmpty) {
      return firebaseName;
    }

    final googleName = googleDisplayName?.trim();
    if (googleName != null && googleName.isNotEmpty) {
      return googleName;
    }

    return _nameFromEmail(_resolveEmail(firebaseEmail, googleEmail));
  }

  String _resolveEmail(String? firebaseEmail, String? googleEmail) {
    final firebaseValue = firebaseEmail?.trim();
    if (firebaseValue != null && firebaseValue.isNotEmpty) {
      return firebaseValue;
    }

    final googleValue = googleEmail?.trim();
    if (googleValue != null && googleValue.isNotEmpty) {
      return googleValue;
    }

    return 'user@local.invalid';
  }

  String _mapFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email ou senha invalidos.';
      case 'email-already-in-use':
        return 'Este email ja esta cadastrado. Faca login.';
      case 'weak-password':
        return 'A senha precisa ter pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'Email invalido.';
      case 'operation-not-allowed':
        return 'Ative o metodo Email/Senha no Firebase Authentication.';
      default:
        return error.message ?? 'Erro ao autenticar no Firebase.';
    }
  }
}
