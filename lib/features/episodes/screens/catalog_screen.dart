import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../watched/providers/watched_provider.dart';
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
        title: const Text('Catálogo de Episódios'),
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
      body: Consumer3<EpisodeProvider, FavoritesProvider, WatchedProvider>(
        builder: (
          BuildContext context,
          EpisodeProvider episodeProvider,
          FavoritesProvider favoritesProvider,
          WatchedProvider watchedProvider,
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
                          hintText: 'Buscar episódio por nome...',
                          prefixIcon: Icon(Icons.search),
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
                child: _buildContent(
                  episodeProvider,
                  favoritesProvider,
                  watchedProvider,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: episodeProvider.isLoading || !episodeProvider.hasMore
                        ? null
                        : () => episodeProvider.loadMoreEpisodes(),
                    child: episodeProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Carregar mais'),
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
    WatchedProvider watchedProvider,
  ) {
    if (episodeProvider.isLoading && episodeProvider.episodes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (episodeProvider.episodes.isEmpty) {
      return const Center(child: Text('Nenhum episódio encontrado.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: episodeProvider.episodes.length,
      itemBuilder: (BuildContext context, int index) {
        final EpisodeModel episode = episodeProvider.episodes[index];
        final bool isFavorite = favoritesProvider.isFavorite(episode.id);
        final bool isWatched = watchedProvider.isWatched(episode.id);

        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRouter.episodeDetailsRoute,
                arguments: episode,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 60,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.green.shade100,
                    ),
                    child: Text(
                      episode.episodeCode,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green.shade900,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Semantics(
                        button: true,
                        label: isWatched
                            ? 'Episódio assistido'
                            : 'Marcar como assistido',
                        child: IconButton(
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () =>
                              watchedProvider.toggleWatched(episode.id),
                          icon: Icon(
                            isWatched
                                ? Icons.visibility
                                : Icons.visibility_outlined,
                            color: isWatched ? Colors.green : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        button: true,
                        label: isFavorite
                            ? 'Remover favorito'
                            : 'Adicionar favorito',
                        child: IconButton(
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () =>
                              favoritesProvider.toggleFavorite(episode.id),
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
