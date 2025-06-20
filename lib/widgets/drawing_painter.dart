import 'package:flutter/material.dart';
import '../models/line.dart';
import '../models/rectangle_shape.dart';
import '../models/circle_shape.dart';
import '../models/ellipse_shape.dart';
import '../models/drawing_layer.dart';
import '../models/view_mode.dart';

class DrawingPainter extends CustomPainter {
  final List<DrawingLayer> layers;
  final bool showEraser;
  final Offset? eraserPosition;
  final double eraserRadius;
  final double gridSpacing;
  final Offset panOffset;

  final Line? pendingLine;
  final RectangleShape? pendingRectangle;
  final CircleShape? pendingCircle;
  final EllipseShape? pendingEllipse;

  final ViewMode currentView;

  DrawingPainter({
    required this.layers,
    required this.gridSpacing,
    required this.showEraser,
    required this.eraserPosition,
    required this.eraserRadius,
    required this.currentView,
    required this.panOffset,
    this.pendingLine,
    this.pendingRectangle,
    this.pendingCircle,
    this.pendingEllipse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double padding = 40.0;

    // 🟠 Determine base origin from view
    late Offset origin;
    switch (currentView) {
      case ViewMode.front:
        origin = Offset(size.width - padding, size.height - padding);
        break;
      case ViewMode.top:
        origin = Offset(size.width - padding, padding);
        break;
      default:
        origin = Offset(size.width / 2, size.height / 2);
        break;
    }

    // 🔄 Adjust origin with pan offset
    final axisOrigin = origin + panOffset;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    // 🟦 Draw grid lines extended beyond screen
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

    // 🔴 Draw axis lines
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

    _drawAxisLabels(canvas, size, axisOrigin);

    // 🖊️ Draw all layers
    for (var layer in layers) {
      if (!layer.isVisible) continue;

      final linePaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2;

      for (int i = 0; i < layer.lines.length; i++) {
        final start = layer.lines[i].start + panOffset;
        final end = layer.lines[i].end + panOffset;
        canvas.drawLine(start, end, linePaint);

        if (i == 0) _drawCoordinateText(canvas, start, axisOrigin);
        bool isLast = i == layer.lines.length - 1;
        if (isLast) {
          _drawCoordinateText(canvas, end, axisOrigin);
        } else {
          final dx1 = end.dx - start.dx;
          final dy1 = end.dy - start.dy;
          final next = layer.lines[i + 1];
          final dx2 = next.end.dx - next.start.dx;
          final dy2 = next.end.dy - next.start.dy;
          if (dx1 * dy2 != dx2 * dy1) {
            _drawCoordinateText(canvas, end, axisOrigin);
          }
        }
      }

      final rectPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (final rect in layer.rectangles) {
        final r = Rect.fromPoints(
          rect.topLeft + panOffset,
          rect.bottomRight + panOffset,
        );
        canvas.drawRect(r, rectPaint);
        _drawCoordinateText(canvas, r.topLeft, axisOrigin);
        _drawCoordinateText(canvas, r.bottomRight, axisOrigin);
      }

      final circlePaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (final circle in layer.circles) {
        final center = circle.center + panOffset;
        canvas.drawCircle(center, circle.radius, circlePaint);
        _drawCoordinateText(canvas, center, axisOrigin);
        // _drawCoordinateText(center + Offset(circle.radius, 0), axisOrigin);
      }

      final ellipsePaint = Paint()
        ..color = Colors.purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (final ellipse in layer.ellipses) {
        final r = Rect.fromPoints(
          ellipse.topLeft + panOffset,
          ellipse.bottomRight + panOffset,
        );
        canvas.drawOval(r, ellipsePaint);
        _drawCoordinateText(canvas, r.topLeft, axisOrigin);
        _drawCoordinateText(canvas, r.bottomRight, axisOrigin);
      }
    }

    // 🟨 Draw pending shapes
    final pendingPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2;

    if (pendingLine != null) {
      pendingPaint.color = Colors.blue;
      canvas.drawLine(
        pendingLine!.start + panOffset,
        pendingLine!.end + panOffset,
        pendingPaint,
      );
      _drawCoordinateText(canvas, pendingLine!.start + panOffset, axisOrigin);
      _drawCoordinateText(canvas, pendingLine!.end + panOffset, axisOrigin);
    }

    if (pendingRectangle != null) {
      pendingPaint.color = Colors.green;
      final r = Rect.fromPoints(
        pendingRectangle!.topLeft + panOffset,
        pendingRectangle!.bottomRight + panOffset,
      );
      canvas.drawRect(r, pendingPaint);
      _drawCoordinateText(canvas, r.topLeft, axisOrigin);
      _drawCoordinateText(canvas, r.bottomRight, axisOrigin);
    }

    if (pendingCircle != null) {
      pendingPaint.color = Colors.orange;
      final center = pendingCircle!.center + panOffset;
      canvas.drawCircle(center, pendingCircle!.radius, pendingPaint);
      _drawCoordinateText(canvas, center, axisOrigin);
      // _drawCoordinateText(center + Offset(pendingCircle!.radius, 0), axisOrigin);
    }

    if (pendingEllipse != null) {
      pendingPaint.color = Colors.purple;
      final r = Rect.fromPoints(
        pendingEllipse!.topLeft + panOffset,
        pendingEllipse!.bottomRight + panOffset,
      );
      canvas.drawOval(r, pendingPaint);
      _drawCoordinateText(canvas, r.topLeft, axisOrigin);
      _drawCoordinateText(canvas, r.bottomRight, axisOrigin);
    }

    // 🔵 Draw eraser
    if (showEraser && eraserPosition != null) {
      final eraserPaint = Paint()
        ..color = Colors.red.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(eraserPosition! + panOffset, eraserRadius, eraserPaint);
    }
  }

  void _drawAxisLabels(Canvas canvas, Size size, Offset origin) {
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

  void _drawCoordinateText(Canvas canvas, Offset point, Offset axisOrigin) {
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
