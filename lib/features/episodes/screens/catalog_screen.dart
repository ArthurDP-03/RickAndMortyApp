import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../../core/router.dart';
import '../models/episode_model.dart';
import '../providers/episode_provider.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EpisodeProvider>().fetchInitialEpisodes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogo de Episodios'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sair',
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pushReplacementNamed(AppRouter.loginRoute);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Consumer2<EpisodeProvider, FavoritesProvider>(
        builder: (
          BuildContext context,
          EpisodeProvider episodeProvider,
          FavoritesProvider favoritesProvider,
          _,
        ) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Buscar episodio por nome',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: episodeProvider.isLoading ? null : _search,
                      child: const Text('Buscar'),
                    ),
                  ],
                ),
              ),
              if (episodeProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    episodeProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: _buildContent(episodeProvider, favoritesProvider),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: episodeProvider.isLoading || !episodeProvider.hasMore
                        ? null
                        : () => episodeProvider.loadMoreEpisodes(),
                    child: const Text('Carregar mais'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(
    EpisodeProvider episodeProvider,
    FavoritesProvider favoritesProvider,
  ) {
    if (episodeProvider.isLoading && episodeProvider.episodes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (episodeProvider.episodes.isEmpty) {
      return const Center(child: Text('Nenhum episodio encontrado.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.92,
      ),
      itemCount: episodeProvider.episodes.length,
      itemBuilder: (BuildContext context, int index) {
        final EpisodeModel episode = episodeProvider.episodes[index];
        final bool isFavorite = favoritesProvider.isFavorite(episode.id);

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 70,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green.shade100,
                  ),
                  child: Text(
                    episode.episodeCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  episode.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(episode.created),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => favoritesProvider.toggleFavorite(episode.id),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _search() async {
    await context.read<EpisodeProvider>().searchByName(_searchController.text);
  }
}
