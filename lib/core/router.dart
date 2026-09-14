import 'package:flutter/material.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/episodes/screens/catalog_screen.dart';

class AppRouter {
	static const String loginRoute = '/login';
	static const String catalogRoute = '/catalog';

	static Route<dynamic> onGenerateRoute(RouteSettings settings) {
		switch (settings.name) {
			case loginRoute:
				return MaterialPageRoute<void>(
					builder: (_) => const LoginScreen(),
					settings: settings,
				);
			case catalogRoute:
				return MaterialPageRoute<void>(
					builder: (_) => const CatalogScreen(),
					settings: settings,
				);
			default:
				return MaterialPageRoute<void>(
					builder: (_) => const LoginScreen(),
					settings: settings,
				);
		}
	}
}
