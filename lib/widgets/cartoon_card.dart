import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/config/app_colors.dart';

/// Card Estilizado com Borda Cartoonesca e Sombra de Destaque
class CartoonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const CartoonCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor = AppColors.spaceCard,
    this.borderColor = AppColors.borderCartoon,
    this.borderWidth = 2.0,
    this.borderRadius = 16.0,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            offset: const Offset(3, 4),
            blurRadius: 0,
          ),
          BoxShadow(
            color: AppColors.portalGreen.withValues(alpha: 0.08),
            offset: const Offset(0, 0),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(12),
        child: child,
      ),
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: cardContent,
        ),
      );
    }

    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
