import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_app/config/app_colors.dart';
import 'package:rick_and_morty_app/models/character_model.dart';
import 'package:rick_and_morty_app/models/episode_model.dart';
import 'package:rick_and_morty_app/providers/favorites_provider.dart';
import 'package:rick_and_morty_app/providers/watched_provider.dart';
import 'package:rick_and_morty_app/screens/details/widgets/character_card.dart';
import 'package:rick_and_morty_app/services/api_service.dart';
import 'package:rick_and_morty_app/widgets/cartoon_card.dart';
import 'package:rick_and_morty_app/widgets/loading_indicator.dart';

class EpisodeDetailsScreen extends StatefulWidget {
  final Episode episode;

  const EpisodeDetailsScreen({
    super.key,
    required this.episode,
  });

  @override
  State<EpisodeDetailsScreen> createState() => _EpisodeDetailsScreenState();
}

class _EpisodeDetailsScreenState extends State<EpisodeDetailsScreen> {
  late Future<List<Character>> _charactersFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _charactersFuture = _apiService.getCharactersByUrls(widget.episode.characters);
  }

  @override
  Widget build(BuildContext context) {
    final episode = widget.episode;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final watchedProvider = context.watch<WatchedProvider>();

    final isFavorite = favoritesProvider.isFavorite(episode.id);
    final isWatched = watchedProvider.isWatched(episode.id);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Voltar para o catálogo',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          episode.episode,
          style: GoogleFonts.bangers(
            fontSize: 22,
            color: AppColors.mortyYellow,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isWatched
                  ? Icons.remove_red_eye_rounded
                  : Icons.remove_red_eye_outlined,
              color: isWatched ? AppColors.mortyYellow : AppColors.textMuted,
              size: 26,
            ),
            tooltip: isWatched
                ? 'Marcado como Assistido (Toque para desmarcar)'
                : 'Marcar como Assistido',
            onPressed: () {
              watchedProvider.toggleWatched(episode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  backgroundColor: isWatched
                      ? AppColors.spaceCardLight
                      : AppColors.portalGreenDark,
                  content: Text(
                    isWatched
                        ? 'Episódio removido da lista de assistidos.'
                        : 'Episódio marcado como assistido! 👁️',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? AppColors.portalLime : AppColors.textMuted,
              size: 26,
            ),
            tooltip: isFavorite
                ? 'Favoritado (Toque para remover)'
                : 'Adicionar aos Favoritos',
            onPressed: () {
              favoritesProvider.toggleFavorite(episode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  backgroundColor: isFavorite
                      ? AppColors.spaceCardLight
                      : AppColors.portalGreenDark,
                  content: Text(
                    isFavorite
                        ? 'Episódio removido dos favoritos.'
                        : 'Episódio adicionado aos favoritos! 💚',
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CartoonCard(
                  padding: EdgeInsets.zero,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: episode.thumbnailPlaceholder,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.spaceCardLight,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.portalGreen,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.spaceCardLight,
                              child: const Icon(
                                Icons.tv_rounded,
                                size: 80,
                                color: AppColors.portalLime,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(14),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.9),
                              ],
                            ),
                          ),
                          child: Text(
                            episode.name,
                            style: GoogleFonts.bangers(
                              fontSize: 26,
                              color: AppColors.portalGreen,
                              letterSpacing: 1.2,
                              shadows: [
                                const Shadow(
                                  color: Colors.black,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CartoonCard(
                  backgroundColor: AppColors.spaceCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DADOS DA TRANSMISSÃO',
                        style: GoogleFonts.bangers(
                          fontSize: 18,
                          color: AppColors.mortyYellow,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.movie_filter_rounded,
                        label: 'Nome (name)',
                        value: episode.name,
                      ),
                      _buildInfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Data no Ar (air_date)',
                        value: episode.airDate,
                      ),
                      _buildInfoRow(
                        icon: Icons.confirmation_number_rounded,
                        label: 'Código (episode)',
                        value: episode.episode,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.groups_rounded,
                      color: AppColors.portalGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PERSONAGENS NO EPISÓDIO (${episode.characters.length})',
                      style: GoogleFonts.bangers(
                        fontSize: 20,
                        color: AppColors.portalGreen,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Character>>(
                  future: _charactersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: LoadingIndicator(
                          message: 'Identificando criaturas do multiverso...',
                          size: 36,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return const CartoonCard(
                        child: Text(
                          'Falha ao carregar detalhes dos personagens.',
                          style: TextStyle(color: AppColors.errorRed),
                        ),
                      );
                    }

                    final characters = snapshot.data ?? [];
                    if (characters.isEmpty) {
                      return const CartoonCard(
                        child: Text(
                          'Nenhum personagem registrado para este episódio.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    int crossAxis = screenWidth > 600 ? 2 : 1;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxis,
                        childAspectRatio: crossAxis == 2 ? 3.8 : 4.4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: characters.length,
                      itemBuilder: (context, index) {
                        return CharacterCard(character: characters[index]);
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.portalLime),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value.isNotEmpty ? value : 'Não disponível',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
