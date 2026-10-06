import 'package:flutter/material.dart';

class SubtleHomeGradient extends StatelessWidget {
  const SubtleHomeGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF06070F),
      child: Stack(
        children: [
          Positioned(
            top: -160,
            right: -120,
            width: 420,
            height: 420,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.26),
                    const Color(0xFF6D28D9).withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          Positioned(
            top: 200,
            left: -140,
            width: 400,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.22),
                    const Color(0xFF1D4ED8).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -140,
            left: -90,
            width: 460,
            height: 460,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF22D3EE).withValues(alpha: 0.18),
                    const Color(0xFF0E7490).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 60,
            right: -80,
            width: 280,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFEC4899).withValues(alpha: 0.16),
                    const Color(0xFFBE185D).withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          Positioned(
            top: 60,
            left: 40,
            width: 220,
            height: 220,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.14),
                    const Color(0xFF4338CA).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0.42),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.3,
                  colors: [
                    Colors.white.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
