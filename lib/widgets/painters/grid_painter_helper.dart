import 'package:flutter/material.dart';

void drawGrid(Canvas canvas, Size size, Offset panOffset, double gridSpacing) {
  final gridPaint = Paint()
    ..color = Colors.grey.withOpacity(0.3)
    ..strokeWidth = 1;

  for (double x = -panOffset.dx % gridSpacing - gridSpacing * 2;
      x <= size.width + gridSpacing * 2;
      x += gridSpacing) {
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
  }

  for (double y = -panOffset.dy % gridSpacing - gridSpacing * 2;
      y <= size.height + gridSpacing * 2;
      y += gridSpacing) {
    canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
  }
}
