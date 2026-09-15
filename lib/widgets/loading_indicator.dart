import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/config/app_colors.dart';

/// Indicador de Carregamento Temático com Feedback de Acessibilidade (RF09, RF10)
class LoadingIndicator extends StatelessWidget {
  final String message;
  final double size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.message = 'Carregando dimensões...',
    this.size = 50.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: message,
      liveRegion: true,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? AppColors.portalGreen,
                ),
                backgroundColor: AppColors.spaceCardLight,
              ),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.portalLime,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
