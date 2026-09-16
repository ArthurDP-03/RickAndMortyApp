import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/screens/catalog/catalog_screen.dart';
import 'package:rick_and_morty_app/screens/favorites/favorites_screen.dart';
import 'package:rick_and_morty_app/screens/profile/profile_screen.dart';
import 'package:rick_and_morty_app/screens/watched/watched_screen.dart';
import 'package:rick_and_morty_app/widgets/custom_bottom_nav.dart';

class MainShellScreen extends StatefulWidget {
  final int initialIndex;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    CatalogScreen(),
    ProfileScreen(),
    FavoritesScreen(),
    WatchedScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
