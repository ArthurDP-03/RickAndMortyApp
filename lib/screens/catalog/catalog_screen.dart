import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_app/config/app_colors.dart';
import 'package:rick_and_morty_app/providers/episode_provider.dart';
import 'package:rick_and_morty_app/screens/catalog/widgets/catalog_search_bar.dart';
import 'package:rick_and_morty_app/screens/catalog/widgets/episode_grid_card.dart';
import 'package:rick_and_morty_app/screens/catalog/widgets/filter_modal.dart';
import 'package:rick_and_morty_app/widgets/custom_button.dart';
import 'package:rick_and_morty_app/widgets/error_view.dart';
import 'package:rick_and_morty_app/widgets/loading_indicator.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EpisodeProvider>();
      if (provider.episodes.isEmpty) {
        provider.fetchEpisodes();
      }
    });
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final episodeProvider = context.watch<EpisodeProvider>();
    final episodes = episodeProvider.episodes;
    final width = MediaQuery.of(context).size.width;

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
        title: const Text('CATÁLOGO DE EPISÓDIOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recarregar Catálogo',
            onPressed: () => episodeProvider.fetchEpisodes(reset: true),
          ),
        ],
      ),
      body: Column(
        children: [
          CatalogSearchBar(
            onFilterTap: _openFilterModal,
          ),
          if (episodeProvider.searchQuery.isNotEmpty ||
              episodeProvider.filterSeason.isNotEmpty ||
              episodeProvider.filterAirDate.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (episodeProvider.searchQuery.isNotEmpty)
                      _buildActiveFilterChip(
                        label: 'Nome: "${episodeProvider.searchQuery}"',
                        onDeleted: () => episodeProvider.applyFilters(
                          name: '',
                          season: episodeProvider.filterSeason,
                          airDate: episodeProvider.filterAirDate,
                        ),
                      ),
                    if (episodeProvider.filterSeason.isNotEmpty)
                      _buildActiveFilterChip(
                        label: 'Temp: "${episodeProvider.filterSeason}"',
                        onDeleted: () => episodeProvider.applyFilters(
                          name: episodeProvider.searchQuery,
                          season: '',
                          airDate: episodeProvider.filterAirDate,
                        ),
                      ),
                    if (episodeProvider.filterAirDate.isNotEmpty)
                      _buildActiveFilterChip(
                        label: 'Data: "${episodeProvider.filterAirDate}"',
                        onDeleted: () => episodeProvider.applyFilters(
                          name: episodeProvider.searchQuery,
                          season: episodeProvider.filterSeason,
                          airDate: '',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (episodeProvider.isLoading && episodes.isEmpty) {
                  return const LoadingIndicator(
                    message: 'Sintonizando frequências interdimensionais...',
                  );
                }

                if (episodeProvider.errorMessage != null && episodes.isEmpty) {
                  return ErrorView(
                    message: episodeProvider.errorMessage!,
                    onRetry: () => episodeProvider.fetchEpisodes(reset: true),
                  );
                }

                if (episodes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.sentiment_dissatisfied_rounded,
                            size: 64,
                            color: AppColors.mortyYellow,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhum episódio encontrado nesta dimensão!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Limpar Filtros',
                            width: 180,
                            onPressed: () => episodeProvider.clearFilters(),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.portalGreen,
                  backgroundColor: AppColors.spaceCard,
                  onRefresh: () => episodeProvider.fetchEpisodes(reset: true),
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(14),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.76,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return EpisodeGridCard(episode: episodes[index]);
                            },
                            childCount: episodes.length,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: 8,
                            bottom: 28,
                          ),
                          child: Center(
                            child: episodeProvider.hasMorePages
                                ? CustomButton(
                                    text: 'CARREGAR MAIS',
                                    icon: Icons.add_circle_outline_rounded,
                                    isLoading: episodeProvider.isLoadingMore,
                                    width: 260,
                                    onPressed: () =>
                                        episodeProvider.loadMoreEpisodes(),
                                    semanticLabel:
                                        'Botão Carregar mais episódios',
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.spaceCardLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '✓ Todos os episódios carregados!',
                                      style: TextStyle(
                                        color: AppColors.portalLime,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
        backgroundColor: AppColors.portalLime,
        deleteIcon: const Icon(Icons.close, size: 16, color: Colors.black),
        onDeleted: onDeleted,
      ),
    );
  }
}
