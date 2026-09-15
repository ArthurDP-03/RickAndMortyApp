import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_app/config/app_theme.dart';
import 'package:rick_and_morty_app/config/env_config.dart';
import 'package:rick_and_morty_app/providers/auth_provider.dart';
import 'package:rick_and_morty_app/providers/episode_provider.dart';
import 'package:rick_and_morty_app/providers/favorites_provider.dart';
import 'package:rick_and_morty_app/providers/watched_provider.dart';
import 'package:rick_and_morty_app/screens/auth/login_screen.dart';
import 'package:rick_and_morty_app/screens/shell/main_shell_screen.dart';
import 'package:rick_and_morty_app/widgets/loading_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa leitura do arquivo .env com fallbacks
  await EnvConfig.initialize();

  runApp(const RickAndMortyApp());
}

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkCurrentSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => EpisodeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => WatchedProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'RM Guide - Rick and Morty',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthGate(),
      ),
    );
  }
}

/// Portão de Autenticação (RF07: O app deve exigir login antes de exibir o catálogo)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: LoadingIndicator(
          message: 'Verificando credenciais interdimensionais...',
        ),
      );
    }

    if (authProvider.isLoggedIn) {
      return const MainShellScreen();
    }

    return const LoginScreen();
  }
}
