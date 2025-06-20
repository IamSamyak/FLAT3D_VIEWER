import 'package:flutter/material.dart';

void drawCoordinateText(Canvas canvas, Offset point, Offset axisOrigin, double gridSpacing) {
  final dx = ((point.dx - axisOrigin.dx) / gridSpacing).round();
  final dy = ((axisOrigin.dy - point.dy) / gridSpacing).round();
  final text = '($dx, $dy)';
  final textPainter = TextPainter(
    text: TextSpan(text: text, style: const TextStyle(fontSize: 10, color: Colors.black)),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(canvas, point + const Offset(5, 5));
}
