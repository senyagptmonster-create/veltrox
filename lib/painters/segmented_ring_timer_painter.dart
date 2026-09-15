import 'dart:math' as math;
import 'package:flutter/material.dart';

class SegmentedRingTimerPainter extends CustomPainter {
  final int milliseconds;

  const SegmentedRingTimerPainter({required this.milliseconds});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 * 0.9;

    // Dial background
    final bgPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Second tick marks (60 ticks)
    final tickPaint = Paint()
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final angle = (i * 2 * math.pi) / 60 - (math.pi / 2);
      final isMajor = i % 5 == 0;
      final tickLength = isMajor ? 12.0 : 6.0;

      tickPaint
        ..color = isMajor ? const Color(0xFF38BDF8) : Colors.white24
        ..strokeWidth = isMajor ? 2.5 : 1.0;

      final start = Offset(center.dx + (radius - tickLength) * math.cos(angle), center.dy + (radius - tickLength) * math.sin(angle));
      final end = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
      canvas.drawLine(start, end, tickPaint);
    }

    // Rotating Sweep Hand
    final currentSeconds = (milliseconds % 60000) / 1000.0;
    final handAngle = (currentSeconds * 2 * math.pi / 60.0) - (math.pi / 2);
    final handEnd = Offset(
      center.dx + (radius * 0.78) * math.cos(handAngle),
      center.dy + (radius * 0.78) * math.sin(handAngle),
    );

    final handPaint = Paint()
      ..color = const Color(0xFFEF4444) // Athletic Crimson hand
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, handEnd, handPaint);
    canvas.drawCircle(center, 6.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant SegmentedRingTimerPainter oldDelegate) {
    return oldDelegate.milliseconds != milliseconds;
  }
}
