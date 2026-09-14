import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../favorites/providers/favorites_provider.dart';
import '../../watched/providers/watched_provider.dart';
import '../models/character_model.dart';
import '../models/episode_model.dart';
import '../services/episode_api_service.dart';

class EpisodeDetailsScreen extends StatefulWidget {
  const EpisodeDetailsScreen({
    super.key,
    required this.episode,
  });

  final EpisodeModel episode;

  @override
  State<EpisodeDetailsScreen> createState() => _EpisodeDetailsScreenState();
}

class _EpisodeDetailsScreenState extends State<EpisodeDetailsScreen> {
  final EpisodeApiService _apiService = EpisodeApiService();
  List<CharacterModel> _characters = <CharacterModel>[];
  bool _isLoadingCharacters = true;
  String? _characterError;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    setState(() {
      _isLoadingCharacters = true;
      _characterError = null;
    });

    try {
      final List<CharacterModel> characters =
          await _apiService.getCharactersByUrls(widget.episode.characters);
      if (mounted) {
        setState(() {
          _characters = characters;
          _isLoadingCharacters = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _characterError = 'Não foi possível carregar os personagens.';
          _isLoadingCharacters = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final EpisodeModel episode = widget.episode;
    final String formattedCreatedDate =
        DateFormat('dd/MM/yyyy HH:mm:ss').format(episode.created);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar para o catálogo',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          episode.episodeCode,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          Consumer<FavoritesProvider>(
            builder: (BuildContext context, FavoritesProvider favProvider, _) {
              final bool isFav = favProvider.isFavorite(episode.id);
              return Semantics(
                button: true,
                label: isFav
                    ? 'Remover episódio dos favoritos'
                    : 'Adicionar episódio aos favoritos',
                child: IconButton(
                  tooltip: isFav ? 'Desfavoritar' : 'Favoritar',
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : null,
                  ),
                  onPressed: () => favProvider.toggleFavorite(episode.id),
                ),
              );
            },
          ),
          Consumer<WatchedProvider>(
            builder: (BuildContext context, WatchedProvider watchedProvider, _) {
              final bool isWatched = watchedProvider.isWatched(episode.id);
              return Semantics(
                button: true,
                label: isWatched
                    ? 'Marcar episódio como não assistido'
                    : 'Marcar episódio como assistido',
                child: IconButton(
                  tooltip: isWatched ? 'Assistido' : 'Marcar como assistido',
                  icon: Icon(
                    isWatched ? Icons.visibility : Icons.visibility_outlined,
                    color: isWatched ? Colors.green : null,
                  ),
                  onPressed: () => watchedProvider.toggleWatched(episode.id),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header do Episódio
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            episode.episodeCode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            episode.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Data de Lançamento (air_date)',
                      value: episode.airDate,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      icon: Icons.link,
                      label: 'Endpoint API (url)',
                      value: episode.url,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      icon: Icons.access_time,
                      label: 'Registro no Banco (created)',
                      value: formattedCreatedDate,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Título da Seção de Personagens
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Personagens no Episódio (${episode.characters.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (_characterError != null)
                  TextButton.icon(
                    onPressed: _loadCharacters,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Recarregar'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de Personagens
            _buildCharactersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 20, color: Colors.green.shade800),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCharactersSection() {
    if (_isLoadingCharacters) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Carregando personagens...'),
            ],
          ),
        ),
      );
    }

    if (_characterError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            _characterError!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_characters.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Nenhum personagem encontrado para este episódio.'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _characters.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final CharacterModel character = _characters[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: character.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: character.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image),
                      ),
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person),
                    ),
            ),
            title: Text(
              character.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${character.species} • Status: ${character.status}',
              style: TextStyle(
                color: character.status == 'Alive'
                    ? Colors.green.shade700
                    : character.status == 'Dead'
                        ? Colors.red
                        : Colors.grey.shade700,
              ),
            ),
          ),
        );
      },
    );
  }
}
