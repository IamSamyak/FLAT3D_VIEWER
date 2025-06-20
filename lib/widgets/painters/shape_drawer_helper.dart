import 'package:flat3d_viewer/models/arc.dart';
import 'package:flat3d_viewer/models/circle_shape.dart';
import 'package:flat3d_viewer/models/drawing_layer.dart';
import 'package:flat3d_viewer/models/ellipse_shape.dart';
import 'package:flat3d_viewer/models/ellipse_arc.dart'; // ✅ New import
import 'package:flat3d_viewer/models/line.dart';
import 'package:flat3d_viewer/models/rectangle_shape.dart';
import 'package:flutter/material.dart';

import 'coordinate_text_helper.dart';

void drawShapesAndLayers(Canvas canvas, List<DrawingLayer> layers, Offset axisOrigin, Offset panOffset, double gridSpacing) {
  for (var layer in layers) {
    if (!layer.isVisible) continue;

    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;

    for (int i = 0; i < layer.lines.length; i++) {
      final start = layer.lines[i].start + panOffset;
      final end = layer.lines[i].end + panOffset;
      canvas.drawLine(start, end, linePaint);

      if (i == 0) drawCoordinateText(canvas, start, axisOrigin, gridSpacing);
      bool isLast = i == layer.lines.length - 1;
      if (isLast) {
        drawCoordinateText(canvas, end, axisOrigin, gridSpacing);
      } else {
        final dx1 = end.dx - start.dx;
        final dy1 = end.dy - start.dy;
        final next = layer.lines[i + 1];
        final dx2 = next.end.dx - next.start.dx;
        final dy2 = next.end.dy - next.start.dy;
        if (dx1 * dy2 != dx2 * dy1) {
          drawCoordinateText(canvas, end, axisOrigin, gridSpacing);
        }
      }
    }

    final rectPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final rect in layer.rectangles) {
      final r = Rect.fromPoints(rect.topLeft + panOffset, rect.bottomRight + panOffset);
      canvas.drawRect(r, rectPaint);
      drawCoordinateText(canvas, r.topLeft, axisOrigin, gridSpacing);
      drawCoordinateText(canvas, r.bottomRight, axisOrigin, gridSpacing);
    }

    final circlePaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final circle in layer.circles) {
      final center = circle.center + panOffset;
      canvas.drawCircle(center, circle.radius, circlePaint);
      drawCoordinateText(canvas, center, axisOrigin, gridSpacing);
    }

    final ellipsePaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final ellipse in layer.ellipses) {
      final r = Rect.fromPoints(ellipse.topLeft + panOffset, ellipse.bottomRight + panOffset);
      canvas.drawOval(r, ellipsePaint);
      drawCoordinateText(canvas, r.topLeft, axisOrigin, gridSpacing);
      drawCoordinateText(canvas, r.bottomRight, axisOrigin, gridSpacing);
    }

    final arcPaint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final arc in layer.arcs) {
      final center = arc.center + panOffset;
      final rect = Rect.fromCircle(center: center, radius: arc.radius);
      canvas.drawArc(rect, arc.startAngle, arc.sweepAngle, false, arcPaint);
      drawCoordinateText(canvas, center, axisOrigin, gridSpacing);
    }

    final ellipseArcPaint = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final arc in layer.ellipseArcs) {
      final rect = Rect.fromCenter(
        center: arc.center + panOffset,
        width: arc.radiusX * 2,
        height: arc.radiusY * 2,
      );
      canvas.drawArc(rect, arc.startAngle, arc.sweepAngle, false, ellipseArcPaint);
      drawCoordinateText(canvas, arc.center + panOffset, axisOrigin, gridSpacing);
    }
  }
}

void drawPendingShapes(
  Canvas canvas,
  Offset axisOrigin,
  Offset panOffset,
  double gridSpacing,
  Line? line,
  RectangleShape? rectangle,
  CircleShape? circle,
  EllipseShape? ellipse,
  Arc? arc,
  EllipseArc? ellipseArc, // ✅ New optional param
) {
  final pendingPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  if (line != null) {
    pendingPaint.color = Colors.blue;
    canvas.drawLine(line.start + panOffset, line.end + panOffset, pendingPaint);
    drawCoordinateText(canvas, line.start + panOffset, axisOrigin, gridSpacing);
    drawCoordinateText(canvas, line.end + panOffset, axisOrigin, gridSpacing);
  }

  if (rectangle != null) {
    pendingPaint.color = Colors.green;
    final r = Rect.fromPoints(rectangle.topLeft + panOffset, rectangle.bottomRight + panOffset);
    canvas.drawRect(r, pendingPaint);
    drawCoordinateText(canvas, r.topLeft, axisOrigin, gridSpacing);
    drawCoordinateText(canvas, r.bottomRight, axisOrigin, gridSpacing);
  }

  if (circle != null) {
    pendingPaint.color = Colors.orange;
    final center = circle.center + panOffset;
    canvas.drawCircle(center, circle.radius, pendingPaint);
    drawCoordinateText(canvas, center, axisOrigin, gridSpacing);
  }

  if (ellipse != null) {
    pendingPaint.color = Colors.purple;
    final r = Rect.fromPoints(ellipse.topLeft + panOffset, ellipse.bottomRight + panOffset);
    canvas.drawOval(r, pendingPaint);
    drawCoordinateText(canvas, r.topLeft, axisOrigin, gridSpacing);
    drawCoordinateText(canvas, r.bottomRight, axisOrigin, gridSpacing);
  }

  if (arc != null) {
    pendingPaint.color = Colors.teal;
    final rect = Rect.fromCircle(center: arc.center + panOffset, radius: arc.radius);
    canvas.drawArc(rect, arc.startAngle, arc.sweepAngle, false, pendingPaint);
    drawCoordinateText(canvas, arc.center + panOffset, axisOrigin, gridSpacing);
  }

  if (ellipseArc != null) {
    pendingPaint.color = Colors.deepPurple;
    final rect = Rect.fromCenter(
      center: ellipseArc.center + panOffset,
      width: ellipseArc.radiusX * 2,
      height: ellipseArc.radiusY * 2,
    );
    canvas.drawArc(rect, ellipseArc.startAngle, ellipseArc.sweepAngle, false, pendingPaint);
    drawCoordinateText(canvas, ellipseArc.center + panOffset, axisOrigin, gridSpacing);
  }
}
