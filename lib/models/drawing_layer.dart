import 'line_segment.dart';
import 'rectangle_shape.dart';
import 'circle_shape.dart';
import 'ellipse_shape.dart';
import 'arc.dart';
import 'ellipse_arc.dart'; // ✅ Make sure this exists

class DrawingLayer {
  final String name;
  bool isVisible;
  bool isLocked;

  List<LineSegment> lines;
  List<RectangleShape> rectangles;
  List<CircleShape> circles;
  List<EllipseShape> ellipses;
  List<Arc> arcs;
  List<EllipseArc> ellipseArcs; // ✅ New: for partially erased ellipses

  DrawingLayer({
    required this.name,
    this.isVisible = true,
    this.isLocked = false,
    List<LineSegment>? lines,
    List<RectangleShape>? rectangles,
    List<CircleShape>? circles,
    List<EllipseShape>? ellipses,
    List<Arc>? arcs,
    List<EllipseArc>? ellipseArcs,
  })  : lines = lines ?? [],
        rectangles = rectangles ?? [],
        circles = circles ?? [],
        ellipses = ellipses ?? [],
        arcs = arcs ?? [],
        ellipseArcs = ellipseArcs ?? [];

  @override
  String toString() {
    return 'DrawingLayer(name: $name, visible: $isVisible, locked: $isLocked, '
        'lines: $lines, rectangles: $rectangles, circles: $circles, '
        'ellipses: $ellipses, arcs: $arcs, ellipseArcs: $ellipseArcs)';
  }
}
