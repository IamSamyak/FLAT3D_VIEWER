import 'package:flat3d_viewer/models/arc.dart';
import 'package:flat3d_viewer/models/circle_shape.dart';
import 'package:flat3d_viewer/models/drawing_layer.dart';
import 'package:flat3d_viewer/models/ellipse_shape.dart';
import 'package:flat3d_viewer/models/ellipse_arc.dart';
import 'package:flat3d_viewer/models/line.dart';
import 'package:flat3d_viewer/models/rectangle_shape.dart';
import 'package:flutter/material.dart';

import 'grid_painter_helper.dart';
import 'axis_label_helper.dart';
import 'shape_drawer_helper.dart';

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
  final Arc? pendingArc;
  final EllipseArc? pendingEllipseArc;

  DrawingPainter({
    required this.layers,
    required this.gridSpacing,
    required this.showEraser,
    required this.eraserPosition,
    required this.eraserRadius,
    required this.panOffset,
    this.pendingLine,
    this.pendingRectangle,
    this.pendingCircle,
    this.pendingEllipse,
    this.pendingArc,
    this.pendingEllipseArc,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 40.0;

    // ✅ Always fixed origin
    final origin =Offset(size.width - padding, padding);
    final axisOrigin = origin + panOffset;

    drawGrid(canvas, size, panOffset, gridSpacing);
    drawAxis(canvas, size, axisOrigin);
    drawAxisLabels(canvas, size, axisOrigin, gridSpacing);
    drawShapesAndLayers(canvas, layers, axisOrigin, panOffset, gridSpacing);
    drawPendingShapes(
      canvas,
      axisOrigin,
      panOffset,
      gridSpacing,
      pendingLine,
      pendingRectangle,
      pendingCircle,
      pendingEllipse,
      pendingArc,
      pendingEllipseArc,
    );

    if (showEraser && eraserPosition != null) {
      final eraserPaint = Paint()
        ..color = Colors.red.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(eraserPosition! + panOffset, eraserRadius, eraserPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
