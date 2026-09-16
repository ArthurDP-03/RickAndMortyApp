import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_app/config/app_colors.dart';
import 'package:rick_and_morty_app/providers/auth_provider.dart';
import 'package:rick_and_morty_app/screens/auth/register_screen.dart';
import 'package:rick_and_morty_app/screens/shell/main_shell_screen.dart';
import 'package:rick_and_morty_app/widgets/custom_button.dart';
import 'package:rick_and_morty_app/widgets/custom_text_field.dart';
import 'package:rick_and_morty_app/widgets/portal_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erro ao realizar login.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithGoogle();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Erro ao entrar com Google.',
          ),
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
        portalColor: AppColors.portalGreen,
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
                        fontSize: 38,
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
                      'RM GUIDE • DIMENSÃO C-137',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bangers(
                        fontSize: 16,
                        color: AppColors.mortyYellow,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.spaceCard,
                          border: Border.all(
                            color: AppColors.mortyYellow,
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mortyYellow.withValues(alpha: 0.4),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://rickandmortyapi.com/api/character/avatar/2.jpeg',
                            fit: BoxFit.cover,
                            semanticLabel: 'Avatar do Morty Smith para tela de Login',
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.person_pin,
                              size: 60,
                              color: AppColors.mortyYellow,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _emailController,
                      label: 'E-mail',
                      hint: 'morty@citadel.com',
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
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Senha',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_rounded,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe sua senha.';
                        }
                        if (value.length < 6) {
                          return 'Mínimo de 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'LOGIN',
                      backgroundColor: AppColors.portalGreen,
                      textColor: Colors.black,
                      isLoading: authProvider.isLoading,
                      onPressed: _handleLogin,
                      semanticLabel: 'Botão Entrar no Aplicativo',
                    ),
                    const SizedBox(height: 14),
                    CustomButton(
                      text: 'ENTRAR COM GOOGLE',
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      borderColor: Colors.black26,
                      icon: Icons.g_mobiledata_rounded,
                      isLoading: authProvider.isLoading,
                      onPressed: _handleGoogleLogin,
                      semanticLabel: 'Botão Entrar com Google',
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Não tem conta? ',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Cadastrar-se',
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
