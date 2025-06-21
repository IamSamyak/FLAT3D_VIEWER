import 'package:flat3d_viewer/models/line_segment.dart';
import 'package:flat3d_viewer/models/circle_shape.dart';
import 'package:flat3d_viewer/models/drawing_layer.dart';

import '../models/point3d.dart';
import '../models/line3d.dart';
import '../models/sphere.dart';
import '../models/object3d.dart';

class Object3DReconstructor {
  static Object3D fromViews({
    required DrawingLayer top,
    required DrawingLayer front,
    required DrawingLayer side,
  }) {
    final lines3D = _buildLines(top, front, side);
    final spheres = _buildSpheres(top.circles, front.circles, side.circles);

    return Object3D(lines: lines3D, spheres: spheres);
  }

  static List<Line3D> _buildLines(
    DrawingLayer top,
    DrawingLayer front,
    DrawingLayer side,
  ) {
    final List<Line3D> result = [];

    for (var topLine in top.lines) {
      final x1 = topLine.start.dx;
      final z1 = topLine.start.dy;
      final x2 = topLine.end.dx;
      final z2 = topLine.end.dy;

      final frontLine = front.lines.firstWhere(
        (line) => (line.start.dx - x1).abs() < 1e-2,
        orElse: () => LineSegment(start: topLine.start, end: topLine.start),
      );

      final sideLine = side.lines.firstWhere(
        (line) => (line.start.dx - z1).abs() < 1e-2,
        orElse: () => LineSegment(start: topLine.start, end: topLine.start),
      );

      final y1 = frontLine.start.dy;
      final y2 = sideLine.start.dy;

      result.add(Line3D(
        start: Point3D(x1, y1, z1),
        end: Point3D(x2, y2, z2),
      ));
    }

    return result;
  }

  static List<Sphere> _buildSpheres(
    List<CircleShape> topCircles,
    List<CircleShape> frontCircles,
    List<CircleShape> sideCircles,
  ) {
    final spheres = <Sphere>[];

    for (var top in topCircles) {
      final x = top.center.dx;
      final z = top.center.dy;
      final r = top.radius;

      final front = frontCircles.firstWhere(
        (c) => (c.center.dx - x).abs() < 1e-2 && (c.radius - r).abs() < 1e-2,
        orElse: () => CircleShape(center: top.center, radius: -1),
      );

      if (front.radius == -1) continue;

      final y = front.center.dy;

      final side = sideCircles.firstWhere(
        (c) => (c.center.dx - z).abs() < 1e-2 && (c.radius - r).abs() < 1e-2,
        orElse: () => CircleShape(center: top.center, radius: -1),
      );

      if (side.radius == -1) continue;

      spheres.add(Sphere(center: Point3D(x, y, z), radius: r));
    }

    return spheres;
  }
}
