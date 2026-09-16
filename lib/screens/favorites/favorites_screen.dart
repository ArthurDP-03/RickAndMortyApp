import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_app/config/app_colors.dart';
import 'package:rick_and_morty_app/providers/favorites_provider.dart';
import 'package:rick_and_morty_app/screens/catalog/widgets/episode_grid_card.dart';
import 'package:rick_and_morty_app/widgets/custom_button.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _displayedLimit = 10;

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final allFavorites = favoritesProvider.favorites;
    final width = MediaQuery.of(context).size.width;

    final visibleFavorites = allFavorites.take(_displayedLimit).toList();
    final hasMore = visibleFavorites.length < allFavorites.length;

    int crossAxisCount = 2;
    if (width > 1200) {
      crossAxisCount = 5;
    } else if (width > 800) {
      crossAxisCount = 4;
    } else if (width > 550) {
      crossAxisCount = 3;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAVORITOS (${allFavorites.length})',
          style: GoogleFonts.bangers(
            fontSize: 22,
            color: AppColors.portalLime,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: allFavorites.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.portalLime.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.portalLime, width: 2),
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 64,
                        color: AppColors.portalLime,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Nenhum episódio favoritado ainda!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bangers(
                        fontSize: 22,
                        color: AppColors.portalGreen,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explore o catálogo e toque no ícone de coração nos detalhes do episódio.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(14),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.76,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return EpisodeGridCard(episode: visibleFavorites[index]);
                      },
                      childCount: visibleFavorites.length,
                    ),
                  ),
                ),
                if (hasMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 8,
                        bottom: 28,
                      ),
                      child: Center(
                        child: CustomButton(
                          text: 'CARREGAR MAIS (+10)',
                          icon: Icons.add_circle_outline_rounded,
                          width: 260,
                          onPressed: () {
                            setState(() {
                              _displayedLimit += 10;
                            });
                          },
                          semanticLabel: 'Carregar mais 10 favoritos',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
