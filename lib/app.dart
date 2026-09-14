import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/favorites/providers/favorites_provider.dart';
import 'features/watched/providers/watched_provider.dart';
import 'features/episodes/providers/episode_provider.dart';

class RMGuideApp extends StatelessWidget {
	const RMGuideApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MultiProvider(
			providers: [
				ChangeNotifierProvider<AuthProvider>(
					create: (_) => AuthProvider(),
				),
				ChangeNotifierProvider<EpisodeProvider>(
					create: (_) => EpisodeProvider(),
				),
				ChangeNotifierProvider<FavoritesProvider>(
					create: (_) => FavoritesProvider(),
				),
				ChangeNotifierProvider<WatchedProvider>(
					create: (_) => WatchedProvider(),
				),
			],
			child: MaterialApp(
				title: 'RM Guide',
				debugShowCheckedModeBanner: false,
				theme: ThemeData(
					colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C8A4B)),
					useMaterial3: true,
				),
				initialRoute: AppRouter.loginRoute,
				onGenerateRoute: AppRouter.onGenerateRoute,
			),
		);
	}
}
