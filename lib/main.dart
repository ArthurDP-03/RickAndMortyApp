import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:rick_and_morty_app/config/app_theme.dart';
import 'package:rick_and_morty_app/config/env_config.dart';
import 'package:rick_and_morty_app/config/firebase_options.dart';
import 'package:rick_and_morty_app/providers/auth_provider.dart';
import 'package:rick_and_morty_app/providers/episode_provider.dart';
import 'package:rick_and_morty_app/providers/favorites_provider.dart';
import 'package:rick_and_morty_app/providers/watched_provider.dart';
import 'package:rick_and_morty_app/screens/auth/login_screen.dart';
import 'package:rick_and_morty_app/screens/shell/main_shell_screen.dart';
import 'package:rick_and_morty_app/widgets/loading_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.initialize();

  if (EnvConfig.isFirebaseConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

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
        ChangeNotifierProxyProvider<AuthProvider, FavoritesProvider>(
          create: (_) => FavoritesProvider(),
          update: (_, authProvider, favoritesProvider) {
            favoritesProvider?.setCurrentUser(authProvider.currentUser);
            return favoritesProvider ?? FavoritesProvider();
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, WatchedProvider>(
          create: (_) => WatchedProvider(),
          update: (_, authProvider, watchedProvider) {
            watchedProvider?.setCurrentUser(authProvider.currentUser);
            return watchedProvider ?? WatchedProvider();
          },
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
