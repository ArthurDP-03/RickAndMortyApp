import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_app/config/app_colors.dart';
import 'package:rick_and_morty_app/providers/episode_provider.dart';
import 'package:rick_and_morty_app/screens/details/episode_details_screen.dart';

/// Barra de Pesquisa com TextField, TextEditingController e Botão Buscar (RF08)
class CatalogSearchBar extends StatefulWidget {
  final VoidCallback? onFilterTap;

  const CatalogSearchBar({
    super.key,
    this.onFilterTap,
  });

  @override
  State<CatalogSearchBar> createState() => _CatalogSearchBarState();
}

class _CatalogSearchBarState extends State<CatalogSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    final episodeProvider = context.read<EpisodeProvider>();

    final matchedEpisode = await episodeProvider.searchDirectEpisode(query);

    if (!mounted) return;
    setState(() => _isSearching = false);

    if (matchedEpisode != null) {
      // Navega direto para a tela de detalhes do item encontrado (RF08)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EpisodeDetailsScreen(episode: matchedEpisode),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nenhum episódio encontrado para "$query".'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Campo de Busca
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.spaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.portalLime.withValues(alpha: 0.7),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _performSearch(),
                decoration: InputDecoration(
                  hintText: 'Buscar episódio (ex: Pilot, Rick)...',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.portalLime,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            context.read<EpisodeProvider>().fetchEpisodes(reset: true);
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onChanged: (val) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Botão "Buscar" (RF08)
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSearching ? null : _performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.portalGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Colors.black, width: 1.5),
                ),
              ),
              child: _isSearching
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      'Buscar',
                      style: GoogleFonts.bangers(
                        fontSize: 16,
                        letterSpacing: 1.1,
                      ),
                    ),
            ),
          ),

          // Botão de Filtro Avançado
          if (widget.onFilterTap != null) ...[
            const SizedBox(width: 6),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.spaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.portalLime.withValues(alpha: 0.7),
                  width: 1.5,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.portalLime,
                  size: 22,
                ),
                onPressed: widget.onFilterTap,
                tooltip: 'Filtros avançados',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
