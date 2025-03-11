import 'package:flutter/material.dart';
import 'dart:math'; // 추가된 임포트

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.lightBlueAccent.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path = Path();
    double waveHeight = 15.0;
    double waveFrequency = 2.0 * 3.14 / size.width;

    path.moveTo(0, 0);
    for (double x = 0; x <= size.width; x++) {
      double y = waveHeight * sin(waveFrequency * x) + waveHeight;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}