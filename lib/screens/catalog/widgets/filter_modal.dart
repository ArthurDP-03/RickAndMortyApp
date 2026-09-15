import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_app/config/app_colors.dart';
import 'package:rick_and_morty_app/providers/episode_provider.dart';
import 'package:rick_and_morty_app/widgets/custom_button.dart';
import 'package:rick_and_morty_app/widgets/custom_text_field.dart';

/// Modal de Filtros Avançados para o Catálogo (RF01, Filtros da Pág. 7)
class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late TextEditingController _nameController;
  late TextEditingController _seasonController;
  late TextEditingController _airDateController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<EpisodeProvider>();
    _nameController = TextEditingController(text: provider.searchQuery);
    _seasonController = TextEditingController(text: provider.filterSeason);
    _airDateController = TextEditingController(text: provider.filterAirDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _seasonController.dispose();
    _airDateController.dispose();
    super.dispose();
  }

  void _apply() {
    final provider = context.read<EpisodeProvider>();
    provider.applyFilters(
      name: _nameController.text.trim(),
      season: _seasonController.text.trim(),
      airDate: _airDateController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  void _clear() {
    context.read<EpisodeProvider>().clearFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.spaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.portalGreen, width: 2),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FILTROS DO CATÁLOGO',
                  style: GoogleFonts.bangers(
                    fontSize: 20,
                    color: AppColors.portalGreen,
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(color: AppColors.spaceCardLight),
            const SizedBox(height: 12),

            // Filtro 1: Nome do Episódio
            CustomTextField(
              controller: _nameController,
              label: 'Nome do Episódio (name)',
              hint: 'ex: Rickmurai Jack, Pilot',
              prefixIcon: Icons.title_rounded,
            ),
            const SizedBox(height: 12),

            // Filtro 2: Código Temporada / Episódio
            CustomTextField(
              controller: _seasonController,
              label: 'Temporada / Código (episode)',
              hint: 'ex: S01, S01E09',
              prefixIcon: Icons.video_library_rounded,
            ),
            const SizedBox(height: 12),

            // Filtro 3: Data de Lançamento
            CustomTextField(
              controller: _airDateController,
              label: 'Data de Lançamento (air_date)',
              hint: 'ex: December 2, 2013, 2014',
              prefixIcon: Icons.calendar_month_rounded,
            ),
            const SizedBox(height: 20),

            // Ações
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clear,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      side: const BorderSide(color: AppColors.errorRed),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Limpar',
                      style: GoogleFonts.bangers(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: 'Aplicar Filtros',
                    onPressed: _apply,
                    height: 48,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
