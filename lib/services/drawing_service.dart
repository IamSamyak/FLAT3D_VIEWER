// services/drawing_service.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/line_segment.dart';
import '../models/arc.dart';

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

  bool circleIntersectsCircle(
    Offset center1,
    double radius1,
    Offset center2,
    double radius2,
  ) {
    return (center1 - center2).distance <= (radius1 + radius2);
  }

  List<Arc> splitCircleIntoArcs(
    Offset center,
    double radius,
    Offset eraseCenter,
    double eraseRadius,
  ) {
    final dist = (center - eraseCenter).distance;

    if (dist > radius + eraseRadius) {
      // No intersection — return full circle as one arc
      return [
        Arc(center: center, radius: radius, startAngle: 0, sweepAngle: 2 * pi),
      ];
    }

    // Compute angle from circle center to eraser center
    final angleToEraseCenter = atan2(
      eraseCenter.dy - center.dy,
      eraseCenter.dx - center.dx,
    );

    // Compute angle offset using law of cosines
    final cosine =
        (pow(radius, 2) + pow(dist, 2) - pow(eraseRadius, 2)) /
        (2 * radius * dist);

    if (cosine.abs() > 1) {
      // Eraser fully covers circle or no real intersection
      return [];
    }

    final angleOffset = acos(cosine);

    final angle1 = (angleToEraseCenter - angleOffset) % (2 * pi);
    final angle2 = (angleToEraseCenter + angleOffset) % (2 * pi);

    // Compute sweep of the erased arc
    final erasedSweep = (angle2 - angle1 + 2 * pi) % (2 * pi);
    final remainingSweep = (2 * pi - erasedSweep);

    if (remainingSweep == 0) {
      // Eraser fully covers circle — nothing remains
      return [];
    }

    // Return only the un-erased arc
    return [
      Arc(
        center: center,
        radius: radius,
        startAngle: angle2,
        sweepAngle: remainingSweep,
      ),
    ];
  }

  bool circleIntersectsEraser(
    Offset circleCenter,
    double circleRadius,
    Offset eraserCenter,
    double eraserRadius,
  ) {
    final distance = (circleCenter - eraserCenter).distance;
    return distance <= circleRadius + eraserRadius;
  }

  bool arcIntersectsEraser(Arc arc, Offset eraseCenter, double eraseRadius) {
    final arcCenter = arc.center;
    final radius = arc.radius;
    final startAngle = arc.startAngle;
    final endAngle = startAngle + arc.sweepAngle;

    const resolution = pi / 180; // Fine resolution for accuracy
    final int steps = (arc.sweepAngle / resolution).ceil();

    for (int i = 0; i <= steps; i++) {
      final angle = startAngle + i * resolution;
      final point =
          arcCenter + Offset(radius * cos(angle), radius * sin(angle));
      if ((point - eraseCenter).distance <= eraseRadius) {
        return true;
      }
    }

    return false;
  }

  List<Arc> splitArcIntoArcs(Arc arc, Offset eraseCenter, double eraseRadius) {
    final arcCenter = arc.center;
    final arcRadius = arc.radius;
    final arcStart = arc.startAngle;
    final arcSweep = arc.sweepAngle;

    const splitResolution = pi / 180; // finer for smoother result
    final int count = (arcSweep / splitResolution).ceil();

    List<Arc> result = [];

    double? currentStart;
    double currentSweep = 0;

    for (int i = 0; i < count; i++) {
      final start = arcStart + i * splitResolution;
      final mid = start + splitResolution / 2;

      final point =
          arcCenter + Offset(arcRadius * cos(mid), arcRadius * sin(mid));

      final isOutside = (point - eraseCenter).distance > eraseRadius;

      if (isOutside) {
        // Start new visible arc segment if not already started
        currentStart ??= start;
        currentSweep += splitResolution;
      } else {
        // Finalize and add current arc segment
        if (currentStart != null && currentSweep > 0) {
          result.add(
            Arc(
              center: arcCenter,
              radius: arcRadius,
              startAngle: currentStart,
              sweepAngle: currentSweep,
            ),
          );
          currentStart = null;
          currentSweep = 0;
        }
      }
    }

    // Finalize if the arc ends while still in visible region
    if (currentStart != null && currentSweep > 0) {
      result.add(
        Arc(
          center: arcCenter,
          radius: arcRadius,
          startAngle: currentStart,
          sweepAngle: currentSweep,
        ),
      );
    }
    return result;
  }
}
