import 'line_segment.dart';
import 'rectangle_shape.dart';
import 'circle_shape.dart';
import 'ellipse_shape.dart';

class DrawingLayer {
  final String name;
  bool isVisible;
  bool isLocked;

  List<LineSegment> lines;
  List<RectangleShape> rectangles;
  List<CircleShape> circles;
  List<EllipseShape> ellipses;

  DrawingLayer({
    required this.name,
    this.isVisible = true,
    this.isLocked = false,
    List<LineSegment>? lines,
    List<RectangleShape>? rectangles,
    List<CircleShape>? circles,
    List<EllipseShape>? ellipses,
  })  : lines = lines ?? [],
        rectangles = rectangles ?? [],
        circles = circles ?? [],
        ellipses = ellipses ?? [];
}
