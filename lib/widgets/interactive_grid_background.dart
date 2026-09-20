import 'package:flutter/material.dart';
import 'dart:math';

class InteractiveGridBackground extends StatefulWidget {
  final Widget child;

  const InteractiveGridBackground({super.key, required this.child});

  @override
  State<InteractiveGridBackground> createState() => _InteractiveGridBackgroundState();
}

class _InteractiveGridBackgroundState extends State<InteractiveGridBackground> {
  Offset _mousePosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _mousePosition = event.localPosition;
        });
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _InteractiveGridPainter(_mousePosition),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _InteractiveGridPainter extends CustomPainter {
  final Offset mousePosition;

  _InteractiveGridPainter(this.mousePosition);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1).withOpacity(0.3)
      ..strokeWidth = 1.0;

    final double step = 40.0;
    
    // Draw vertical lines
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    
    // Draw horizontal lines
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Glow effect at mouse position
    if (mousePosition != Offset.zero) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF60A5FA).withOpacity(0.15),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: mousePosition, radius: 200));

      canvas.drawCircle(mousePosition, 200, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _InteractiveGridPainter oldDelegate) {
    return oldDelegate.mousePosition != mousePosition;
  }
}
