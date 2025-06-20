import 'package:flutter/widgets.dart';

class EllipseArc {
  final Offset center;
  final double radiusX;
  final double radiusY;
  final double rotation; // optional if ellipse is axis-aligned
  final double startAngle;
  final double sweepAngle;

  EllipseArc({
    required this.center,
    required this.radiusX,
    required this.radiusY,
    this.rotation = 0,
    required this.startAngle,
    required this.sweepAngle,
  });
}
