import 'package:flutter/material.dart';

class OrderStatusDashedLinePainter extends CustomPainter {
  OrderStatusDashedLinePainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    const dash = 4.0;
    const gap = 4.0;
    double y = 0;
    final cx = size.width / 2;
    while (y < size.height) {
      final yEnd = (y + dash).clamp(0.0, size.height).toDouble();
      canvas.drawLine(Offset(cx, y), Offset(cx, yEnd), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
