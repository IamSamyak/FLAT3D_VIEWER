import 'package:flutter/material.dart';
import '../models/line.dart';
import '../models/rectangle_shape.dart';
import '../models/circle_shape.dart';
import '../models/ellipse_shape.dart';
import '../models/drawing_layer.dart';

class DrawingPainter extends CustomPainter {
  final List<DrawingLayer> layers;
  final bool showEraser;
  final Offset? eraserPosition;
  final double eraserRadius;
  final double gridSpacing;

  final Line? pendingLine;
  final RectangleShape? pendingRectangle;
  final CircleShape? pendingCircle;
  final EllipseShape? pendingEllipse;

  DrawingPainter({
    required this.layers,
    required this.gridSpacing,
    required this.showEraser,
    required this.eraserPosition,
    required this.eraserRadius,
    this.pendingLine,
    this.pendingRectangle,
    this.pendingCircle,
    this.pendingEllipse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final snappedVertical = (center.dx / gridSpacing).round() * gridSpacing;
    final snappedHorizontal = (center.dy / gridSpacing).round() * gridSpacing;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    // Draw grid
    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw axis lines
    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    canvas.drawLine(
        Offset(snappedVertical, 0), Offset(snappedVertical, size.height), axisPaint);
    canvas.drawLine(
        Offset(0, snappedHorizontal), Offset(size.width, snappedHorizontal), axisPaint);

    // Draw all layers
    for (var layer in layers) {
      if (!layer.isVisible) continue;

      final linePaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2;

      for (var line in layer.lines) {
        canvas.drawLine(line.start, line.end, linePaint);
        _drawCoordinateText(canvas, line.start, Offset(snappedVertical, snappedHorizontal));
        _drawCoordinateText(canvas, line.end, Offset(snappedVertical, snappedHorizontal));
      }

      final rectPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (final rect in layer.rectangles) {
        final r = Rect.fromPoints(rect.topLeft, rect.bottomRight);
        canvas.drawRect(r, rectPaint);
        _drawCoordinateText(canvas, r.topLeft, Offset(snappedVertical, snappedHorizontal));
        _drawCoordinateText(canvas, r.bottomRight, Offset(snappedVertical, snappedHorizontal));
      }

      final circlePaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (final circle in layer.circles) {
        canvas.drawCircle(circle.center, circle.radius, circlePaint);
        _drawCoordinateText(canvas, circle.center, Offset(snappedVertical, snappedHorizontal));
        _drawCoordinateText(canvas, circle.center + Offset(circle.radius, 0),
            Offset(snappedVertical, snappedHorizontal));
      }

      final ellipsePaint = Paint()
        ..color = Colors.purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (final ellipse in layer.ellipses) {
        final r = Rect.fromPoints(ellipse.topLeft, ellipse.bottomRight);
        canvas.drawOval(r, ellipsePaint);
        _drawCoordinateText(canvas, r.topLeft, Offset(snappedVertical, snappedHorizontal));
        _drawCoordinateText(canvas, r.bottomRight, Offset(snappedVertical, snappedHorizontal));
      }
    }

    // Draw pending shapes
    if (pendingLine != null) {
      final paint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2;
      canvas.drawLine(pendingLine!.start, pendingLine!.end, paint);
      _drawCoordinateText(canvas, pendingLine!.start, Offset(snappedVertical, snappedHorizontal));
      _drawCoordinateText(canvas, pendingLine!.end, Offset(snappedVertical, snappedHorizontal));
    }

    if (pendingRectangle != null) {
      final paint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final r = Rect.fromPoints(pendingRectangle!.topLeft, pendingRectangle!.bottomRight);
      canvas.drawRect(r, paint);
      _drawCoordinateText(canvas, r.topLeft, Offset(snappedVertical, snappedHorizontal));
      _drawCoordinateText(canvas, r.bottomRight, Offset(snappedVertical, snappedHorizontal));
    }

    if (pendingCircle != null) {
      final paint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(pendingCircle!.center, pendingCircle!.radius, paint);
      _drawCoordinateText(canvas, pendingCircle!.center, Offset(snappedVertical, snappedHorizontal));
      _drawCoordinateText(
          canvas,
          pendingCircle!.center + Offset(pendingCircle!.radius, 0),
          Offset(snappedVertical, snappedHorizontal));
    }

    if (pendingEllipse != null) {
      final paint = Paint()
        ..color = Colors.purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final r = Rect.fromPoints(pendingEllipse!.topLeft, pendingEllipse!.bottomRight);
      canvas.drawOval(r, paint);
      _drawCoordinateText(canvas, r.topLeft, Offset(snappedVertical, snappedHorizontal));
      _drawCoordinateText(canvas, r.bottomRight, Offset(snappedVertical, snappedHorizontal));
    }

    // Draw eraser
    if (showEraser && eraserPosition != null) {
      final eraserPaint = Paint()
        ..color = Colors.red.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(eraserPosition!, eraserRadius, eraserPaint);
    }
  }

  void _drawCoordinateText(Canvas canvas, Offset point, Offset axisCenter) {
    final dx = ((point.dx - axisCenter.dx) / gridSpacing).round();
    final dy = ((axisCenter.dy - point.dy) / gridSpacing).round();
    final text = '($dx, $dy)';

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 10, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: double.infinity);
    textPainter.paint(canvas, point + const Offset(5, 5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
