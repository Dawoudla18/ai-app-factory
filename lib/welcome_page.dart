import 'package:flutter/material.dart';

/// A welcoming landing page shown when Hala2026 launches.
/// Visually themed around Québec (blue, fleur-de-lis motif) and Canada
/// (red, maple leaf) to reflect the app's local, Québec-first focus.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.onGetStarted});

  final VoidCallback onGetStarted;

  static const _quebecBlue = Color(0xFF003DA5);
  static const _canadaRed = Color(0xFFD52B1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_quebecBlue, Color(0xFF0052CC), Colors.white],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const Spacer(),
                const _EmblemBadge(),
                const SizedBox(height: 24),
                const Text(
                  'Hala2026',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your local expense tracker,\nmade for Québec 🍁',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _FlagChip(label: 'Québec', color: _quebecBlue),
                    SizedBox(width: 12),
                    _FlagChip(label: 'Canada', color: _canadaRed),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _canadaRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onGetStarted,
                    child: const Text(
                      'Get started',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Amounts tracked in Canadian dollars (CAD)',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmblemBadge extends StatelessWidget {
  const _EmblemBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CustomPaint(painter: _MapleLeafPainter()),
    );
  }
}

/// A simple stylized maple-leaf silhouette, drawn from scratch as a
/// generic geometric shape (not a reproduction of any specific artwork
/// or the official flag).
class _MapleLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFD52B1E);
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.50, h * 0.12)
      ..lineTo(w * 0.58, h * 0.32)
      ..lineTo(w * 0.78, h * 0.28)
      ..lineTo(w * 0.68, h * 0.44)
      ..lineTo(w * 0.86, h * 0.50)
      ..lineTo(w * 0.68, h * 0.56)
      ..lineTo(w * 0.76, h * 0.74)
      ..lineTo(w * 0.56, h * 0.66)
      ..lineTo(w * 0.53, h * 0.86)
      ..lineTo(w * 0.47, h * 0.66)
      ..lineTo(w * 0.27, h * 0.74)
      ..lineTo(w * 0.35, h * 0.56)
      ..lineTo(w * 0.17, h * 0.50)
      ..lineTo(w * 0.35, h * 0.44)
      ..lineTo(w * 0.25, h * 0.28)
      ..lineTo(w * 0.45, h * 0.32)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FlagChip extends StatelessWidget {
  const _FlagChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
