import 'package:rick_and_morty_app/config/env_config.dart';
import 'package:rick_and_morty_app/models/user_model.dart';
import 'package:rick_and_morty_app/services/local_storage_service.dart';

/// Serviço Unificado de Autenticação (Local + Suporte a Firebase)
class AuthService {
  /// Realiza login de usuário
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.toLowerCase().trim();

    // Se Firebase estiver configurado no .env, aqui se conecta à API do Firebase Auth
    if (EnvConfig.isFirebaseConfigured) {
      // Exemplo de integração Firebase REST ou SDK quando configurado
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

    // Se a conta não existe, permite login de demonstração se for um e-mail válido
    if (cleanEmail.contains('@') && password.length >= 6) {
      final name = cleanEmail.split('@').first;
      final capitalized =
          name.isNotEmpty ? '${name[0].toUpperCase()}${name.substring(1)}' : 'Viajante Dimensional';
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: capitalized,
        email: cleanEmail,
      );
      await LocalStorageService.saveAccount(cleanEmail, password, newUser);
      await LocalStorageService.saveCurrentUser(newUser);
      return newUser;
    }

    throw Exception('Credenciais inválidas. Verifique seu e-mail e senha.');
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

    final accounts = await LocalStorageService.getRegisteredAccounts();
    if (accounts.containsKey(cleanEmail)) {
      throw Exception('Este e-mail já está cadastrado. Faça login.');
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
    await LocalStorageService.saveCurrentUser(updatedUser);
    return updatedUser;
  }

  /// Desconecta o usuário
  Future<void> logout() async {
    await LocalStorageService.clearSession();
  }

  /// Recupera o usuário atualmente logado
  Future<UserModel?> getCurrentUser() async {
    return await LocalStorageService.getCurrentUser();
  }
}
