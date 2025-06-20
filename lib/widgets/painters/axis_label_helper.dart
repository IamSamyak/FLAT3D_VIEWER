import 'package:flutter/material.dart';

void drawAxis(Canvas canvas, Size size, Offset axisOrigin) {
  final axisPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 2;

  canvas.drawLine(
    Offset(axisOrigin.dx, 0),
    Offset(axisOrigin.dx, size.height),
    axisPaint,
  );
  canvas.drawLine(
    Offset(0, axisOrigin.dy),
    Offset(size.width, axisOrigin.dy),
    axisPaint,
  );
}

void drawAxisLabels(Canvas canvas, Size size, Offset origin, double gridSpacing) {
  const labelStyle = TextStyle(fontSize: 10, color: Colors.black);
  final textPainter = TextPainter(textDirection: TextDirection.ltr);

  for (double x = origin.dx; x <= size.width; x += gridSpacing) {
    final dx = ((x - origin.dx) / gridSpacing).round();
    _drawLabel(canvas, textPainter, Offset(x + 2, origin.dy + 2), dx.toString(), labelStyle);
  }

  for (double x = origin.dx - gridSpacing; x >= 0; x -= gridSpacing) {
    final dx = ((x - origin.dx) / gridSpacing).round();
    _drawLabel(canvas, textPainter, Offset(x + 2, origin.dy + 2), dx.toString(), labelStyle);
  }

  for (double y = origin.dy; y <= size.height; y += gridSpacing) {
    final dy = ((origin.dy - y) / gridSpacing).round();
    _drawLabel(canvas, textPainter, Offset(origin.dx + 2, y + 2), dy.toString(), labelStyle);
  }

  for (double y = origin.dy - gridSpacing; y >= 0; y -= gridSpacing) {
    final dy = ((origin.dy - y) / gridSpacing).round();
    _drawLabel(canvas, textPainter, Offset(origin.dx + 2, y + 2), dy.toString(), labelStyle);
  }
}

void _drawLabel(Canvas canvas, TextPainter tp, Offset pos, String text, TextStyle style) {
  tp.text = TextSpan(text: text, style: style);
  tp.layout();
  tp.paint(canvas, pos);
}
