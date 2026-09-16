import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_app/config/app_colors.dart';
import 'package:rick_and_morty_app/providers/auth_provider.dart';
import 'package:rick_and_morty_app/screens/shell/main_shell_screen.dart';
import 'package:rick_and_morty_app/widgets/custom_button.dart';
import 'package:rick_and_morty_app/widgets/custom_text_field.dart';
import 'package:rick_and_morty_app/widgets/portal_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      birthDate: _birthDateController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erro ao criar conta.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: PortalBackground(
        portalColor: AppColors.rickHairBlue,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'RICK AND MORTY',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.creepster(
                        fontSize: 36,
                        color: AppColors.portalGreen,
                        letterSpacing: 2.0,
                        shadows: [
                          const Shadow(
                            color: Colors.black,
                            offset: Offset(3, 3),
                            blurRadius: 2,
                          ),
                          Shadow(
                            color: AppColors.portalGlow.withValues(alpha: 0.8),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NOVO VIAJANTE INTERDIMENSIONAL',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bangers(
                        fontSize: 16,
                        color: AppColors.rickHairBlue,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.spaceCard,
                          border: Border.all(
                            color: AppColors.rickHairBlue,
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.rickHairBlue.withValues(alpha: 0.4),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
                            fit: BoxFit.cover,
                            semanticLabel: 'Avatar do Rick Sanchez para tela de Cadastro',
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.science_rounded,
                              size: 55,
                              color: AppColors.rickHairBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _nameController,
                      label: 'Nome Completo',
                      hint: 'Rick Sanchez C-137',
                      prefixIcon: Icons.badge_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe seu nome completo.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _emailController,
                      label: 'E-mail',
                      hint: 'rick@citadel.com',
                      prefixIcon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe seu e-mail.';
                        }
                        if (!value.contains('@')) {
                          return 'E-mail inválido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _birthDateController,
                      label: 'Data de Nascimento',
                      hint: 'DD/MM/AAAA',
                      prefixIcon: Icons.calendar_today_rounded,
                      readOnly: true,
                      onTap: _pickBirthDate,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Selecione sua data de nascimento.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Senha',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_rounded,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe uma senha.';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter no mínimo 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirmar Senha',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'As senhas não coincidem.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    CustomButton(
                      text: 'CADASTRAR',
                      backgroundColor: AppColors.rickHairBlue,
                      textColor: Colors.black,
                      isLoading: authProvider.isLoading,
                      onPressed: _handleRegister,
                      semanticLabel: 'Botão Cadastrar Conta',
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Já tem conta? ',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: AppColors.portalLime,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
