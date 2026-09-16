import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rick_and_morty_app/config/app_colors.dart';

class PortalBackground extends StatefulWidget {
  final Widget child;
  final bool showPortalEffect;
  final Color? portalColor;

  const PortalBackground({
    super.key,
    required this.child,
    this.showPortalEffect = true,
    this.portalColor,
  });

  @override
  State<PortalBackground> createState() => _PortalBackgroundState();
}

class _PortalBackgroundState extends State<PortalBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 1.2,
              colors: [
                Color(0xFF142C48),
                AppColors.spaceDark,
                Color(0xFF050B14),
              ],
            ),
          ),
        ),
        if (widget.showPortalEffect)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _PortalPainter(
                    animationValue: _controller.value,
                    portalColor: widget.portalColor ?? AppColors.portalGreen,
                  ),
                );
              },
            ),
          ),
        SafeArea(child: widget.child),
      ],
    );
  }
}

class _PortalPainter extends CustomPainter {
  final double animationValue;
  final Color portalColor;

  _PortalPainter({
    required this.animationValue,
    required this.portalColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.22);
    final maxRadius = size.width * 0.45;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          portalColor.withValues(alpha: 0.35),
          AppColors.portalLime.withValues(alpha: 0.18),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 1.4));

    canvas.drawCircle(center, maxRadius * 1.4, glowPaint);

    for (int i = 1; i <= 4; i++) {
      final ringRadius = maxRadius * (i / 4.0);
      final angleOffset = (animationValue * 2 * math.pi * (i % 2 == 0 ? 1 : -1)) +
          (i * math.pi / 3);

      final ringPaint = Paint()
        ..color = (i % 2 == 0 ? AppColors.portalLime : portalColor)
            .withValues(alpha: 0.15 + (i * 0.05))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 + i;

      final rect = Rect.fromCircle(center: center, radius: ringRadius);
      canvas.drawArc(rect, angleOffset, math.pi * 1.4, false, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PortalPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.portalColor != portalColor;
}
