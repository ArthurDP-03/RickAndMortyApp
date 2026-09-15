import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/config/app_colors.dart';
import 'package:rick_and_morty_app/widgets/custom_button.dart';

/// Tela de Feedback de Erro Amigável com Opção de Recarregar (RF09, RF10)
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.wifi_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.errorRed, width: 2),
              ),
              child: Icon(
                icon,
                size: 56,
                color: AppColors.errorRed,
                semanticLabel: 'Ícone de erro',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Wubba Lubba Dub Dub!',
              style: TextStyle(
                color: AppColors.portalGreen,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: 'Tentar Novamente',
                icon: Icons.refresh_rounded,
                width: 220,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
