import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_app/config/app_colors.dart';
import 'package:rick_and_morty_app/providers/favorites_provider.dart';
import 'package:rick_and_morty_app/providers/watched_provider.dart';

/// Barra de Navegação Inferior com Ícones Temáticos Rick and Morty
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesCount = context.watch<FavoritesProvider>().count;
    final watchedCount = context.watch<WatchedProvider>().count;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.spaceCard,
        border: const Border(
          top: BorderSide(
            color: AppColors.portalGreen,
            width: 2.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.portalGreen.withValues(alpha: 0.15),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Catálogo de Episódios (Ícone Portal)
              _buildNavItem(
                index: 0,
                icon: Icons.blur_circular_rounded,
                label: 'Catálogo',
                semanticLabel: 'Aba Catálogo de Episódios',
              ),

              // 2. Perfil do Usuário (Ícone Perfil)
              _buildNavItem(
                index: 1,
                icon: Icons.person_rounded,
                label: 'Perfil',
                semanticLabel: 'Aba Perfil do Usuário',
              ),

              // 3. Episódios Favoritos (Ícone Coração Gosma Verde)
              _buildNavItem(
                index: 2,
                icon: Icons.favorite_rounded,
                label: 'Favoritos',
                badgeCount: favoritesCount,
                badgeColor: AppColors.portalLime,
                semanticLabel: 'Aba Episódios Favoritos',
              ),

              // 4. Episódios Assistidos (Ícone Olho Temático)
              _buildNavItem(
                index: 3,
                icon: Icons.remove_red_eye_rounded,
                label: 'Assistidos',
                badgeCount: watchedCount,
                badgeColor: AppColors.mortyYellow,
                semanticLabel: 'Aba Episódios Assistidos',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required String semanticLabel,
    int? badgeCount,
    Color badgeColor = AppColors.portalGreen,
  }) {
    final isSelected = currentIndex == index;

    return Semantics(
      label: semanticLabel,
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.portalGreen.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppColors.portalGreen, width: 1.5)
                          : null,
                    ),
                    child: Icon(
                      icon,
                      size: 26,
                      color: isSelected
                          ? AppColors.portalGreen
                          : AppColors.textMuted,
                    ),
                  ),
                  if (badgeCount != null && badgeCount > 0)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.portalGreen
                      : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
