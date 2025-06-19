// services/drawing_service.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/line_segment.dart';

class DrawingService {
  final double gridSpacing;
  final double toolsPanelWidth;

  DrawingService({required this.gridSpacing, required this.toolsPanelWidth});

  Offset snapToGrid(Offset point) {
    return Offset(
      (point.dx / gridSpacing).round() * gridSpacing,
      (point.dy / gridSpacing).round() * gridSpacing,
    );
  }

  Offset adjustedOffset(Offset rawOffset) {
    // Subtract only the width of the Layers panel (left side)
    return Offset(rawOffset.dx - 200, rawOffset.dy);
  }

  bool lineIntersectsCircle(
    Offset p1,
    Offset p2,
    Offset center,
    double radius,
  ) {
    final a = p2.dx - p1.dx;
    final b = p2.dy - p1.dy;
    final dx = p1.dx - center.dx;
    final dy = p1.dy - center.dy;

    final aDot = a * a + b * b;
    final bDot = 2 * (a * dx + b * dy);
    final cDot = dx * dx + dy * dy - radius * radius;

    final discriminant = bDot * bDot - 4 * aDot * cDot;
    return discriminant >= 0;
  }

  List<LineSegment> splitLineAroundCircle(
    Offset p1,
    Offset p2,
    Offset center,
    double radius,
  ) {
    final direction = p2 - p1;
    final length = direction.distance;

    if (length == 0) return [];

    final unit = direction / length;
    final toCenter = center - p1;
    final projection = unit.dx * toCenter.dx + unit.dy * toCenter.dy;
    final clampedProjection = projection.clamp(0.0, length);
    final closestPoint = p1 + unit * clampedProjection;
    final distToCenter = (closestPoint - center).distance;

    if (distToCenter > radius) return [LineSegment(start: p1, end: p2)];

    final offset = sqrt(radius * radius - distToCenter * distToCenter);
    final entryDist = max(0.0, clampedProjection - offset);
    final exitDist = min(length, clampedProjection + offset);

    final entry = p1 + unit * entryDist;
    final exit = p1 + unit * exitDist;

    final snappedEntry = snapToGrid(entry);
    final snappedExit = snapToGrid(exit);

    List<LineSegment> result = [];
    if ((snappedEntry - p1).distance > 1) {
      result.add(LineSegment(start: p1, end: snappedEntry));
    }
    if ((p2 - snappedExit).distance > 1) {
      result.add(LineSegment(start: snappedExit, end: p2));
    }

    return result;
  }
}
