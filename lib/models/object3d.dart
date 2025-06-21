import 'line3d.dart';
import 'sphere.dart';

class Object3D {
  final List<Line3D> lines;
  final List<Sphere> spheres;

  const Object3D({
    this.lines = const [],
    this.spheres = const [],
  });
}
