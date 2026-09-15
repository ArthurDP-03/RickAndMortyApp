import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_app/config/app_colors.dart';
import 'package:rick_and_morty_app/providers/auth_provider.dart';
import 'package:rick_and_morty_app/providers/favorites_provider.dart';
import 'package:rick_and_morty_app/providers/watched_provider.dart';
import 'package:rick_and_morty_app/screens/auth/login_screen.dart';
import 'package:rick_and_morty_app/widgets/cartoon_card.dart';
import 'package:rick_and_morty_app/widgets/custom_button.dart';
import 'package:rick_and_morty_app/widgets/custom_text_field.dart';

/// Tela de Perfil do Usuário com Edição e Estatísticas (Pág. 6)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  bool _isEditing = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _birthDateController.text = user.birthDate ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.portalGreen,
              onPrimary: Colors.black,
              surface: AppColors.spaceCard,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) return;

    final updated = user.copyWith(
      name: _nameController.text.trim(),
      birthDate: _birthDateController.text.trim(),
    );

    final success = await authProvider.updateProfile(updated);
    if (!mounted) return;

    if (success) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: AppColors.portalGreenDark,
        ),
      );
    }
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.spaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.portalGreen, width: 2),
        ),
        title: Text(
          'Desconectar?',
          style: GoogleFonts.bangers(
            color: AppColors.portalGreen,
            fontSize: 22,
          ),
        ),
        content: const Text(
          'Deseja realmente sair da sua sessão nesta dimensão?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final favoritesCount = context.watch<FavoritesProvider>().count;
    final watchedCount = context.watch<WatchedProvider>().count;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PERFIL DO VIAJANTE',
          style: GoogleFonts.bangers(
            fontSize: 22,
            color: AppColors.portalGreen,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit_note_rounded,
              color: AppColors.portalLime,
            ),
            tooltip: _isEditing ? 'Cancelar edição' : 'Editar Perfil',
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing && user != null) {
                  _nameController.text = user.name;
                  _birthDateController.text = user.birthDate ?? '';
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar e Dados Principais
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.spaceCardLight,
                          border: Border.all(
                            color: AppColors.portalGreen,
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.portalGreen.withValues(alpha: 0.3),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 70,
                          color: AppColors.portalGreen,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.portalGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user?.name ?? 'Viajante Anônimo',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bangers(
                    fontSize: 24,
                    color: AppColors.portalGreen,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Painel de Estatísticas
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Favoritos',
                        value: favoritesCount.toString(),
                        icon: Icons.favorite_rounded,
                        color: AppColors.portalLime,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Assistidos',
                        value: watchedCount.toString(),
                        icon: Icons.remove_red_eye_rounded,
                        color: AppColors.mortyYellow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Formulário de Edição / Visualização
                CartoonCard(
                  backgroundColor: AppColors.spaceCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing ? 'EDITAR DADOS' : 'INFORMAÇÕES DA CONTA',
                        style: GoogleFonts.bangers(
                          fontSize: 18,
                          color: AppColors.portalGreen,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _nameController,
                        label: 'Nome de Exibição',
                        readOnly: !_isEditing,
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _birthDateController,
                        label: 'Data de Nascimento',
                        readOnly: true,
                        onTap: _isEditing ? _pickBirthDate : null,
                        prefixIcon: Icons.calendar_today_rounded,
                        hint: 'Não informada',
                      ),
                      if (_isEditing) ...[
                        const SizedBox(height: 18),
                        CustomButton(
                          text: 'SALVAR ALTERAÇÕES',
                          onPressed: _saveProfile,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botão de Logout
                CustomButton(
                  text: 'DESCONECTAR',
                  icon: Icons.logout_rounded,
                  backgroundColor: AppColors.errorRed,
                  textColor: Colors.white,
                  onPressed: _handleLogout,
                  semanticLabel: 'Botão de logout da conta',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return CartoonCard(
      backgroundColor: AppColors.spaceCardLight,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.bangers(
              fontSize: 26,
              color: color,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
