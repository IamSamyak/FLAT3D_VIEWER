import 'package:flat3d_viewer/models/point3d.dart';
import 'package:flutter/material.dart';
import '../models/object3d.dart';
import '../models/line3d.dart';
import '../models/sphere.dart';

class Object3DPreview extends StatelessWidget {
  final Object3D object;

  const Object3DPreview({super.key, required this.object});

  Offset project(Point3D p) {
    // simple isometric-style projection
    double scale = 0.5;
    double px = p.x - p.z;
    double py = (p.x + p.z) / 2 - p.y;
    return Offset(px * scale + 200, py * scale + 200);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(400, 400),
      painter: _ObjectPainter(object, project),
    );
  }
}

class _ObjectPainter extends CustomPainter {
  final Object3D object;
  final Offset Function(Point3D) project;

  _ObjectPainter(this.object, this.project);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (Line3D line in object.lines) {
      final p1 = project(line.start);
      final p2 = project(line.end);
      canvas.drawLine(p1, p2, paint);
    }

    final spherePaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.stroke;

    for (Sphere s in object.spheres) {
      final c = project(s.center);
      canvas.drawCircle(c, s.radius * 0.5, spherePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
