import 'package:flutter/material.dart';
import 'dart:math';
import '../models/tool.dart';

const double gridSize = 20.0;

class OrthographicDrawingArea extends StatefulWidget {
  final List<Map<String, dynamic>> shapes;
  final Tool selectedTool;
  final void Function(Map<String, dynamic>) onShapeDrawn;
  final void Function(List<Map<String, dynamic>>) onShapesUpdated;

  const OrthographicDrawingArea({
    super.key,
    required this.shapes,
    required this.selectedTool,
    required this.onShapeDrawn,
    required this.onShapesUpdated,
  });

  @override
  State<OrthographicDrawingArea> createState() => _OrthographicDrawingAreaState();
}

class _OrthographicDrawingAreaState extends State<OrthographicDrawingArea> {
  Offset? startPoint;
  Offset? currentPoint;

  Offset snapToGrid(Offset point) {
    return Offset(
      (point.dx / gridSize).round() * gridSize,
      (point.dy / gridSize).round() * gridSize,
    );
  }

  void eraseAt(Offset touchPoint) {
    final updatedShapes = <Map<String, dynamic>>[];

    for (final shape in widget.shapes) {
      if (shape['type'] == 'line') {
        final segments = splitLineIntoGridSegments(shape);
        for (final seg in segments) {
          if (_isFarFromTouch(seg, touchPoint)) {
            updatedShapes.add(seg);
          }
        }
      } else {
        updatedShapes.add(shape); // not splitting rectangles or circles yet
      }
    }

    widget.onShapesUpdated(updatedShapes);
  }

  bool _isFarFromTouch(Map<String, dynamic> segment, Offset touchPoint) {
    final start = segment['start'] as Offset;
    final end = segment['end'] as Offset;
    final distance = _distanceToSegment(touchPoint, start, end);
    return distance > gridSize * 0.6; // distance threshold for deletion
  }

  double _distanceToSegment(Offset p, Offset a, Offset b) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    if (dx == 0 && dy == 0) return (p - a).distance;
    final t = ((p.dx - a.dx) * dx + (p.dy - a.dy) * dy) / (dx * dx + dy * dy);
    if (t < 0) return (p - a).distance;
    if (t > 1) return (p - b).distance;
    final proj = Offset(a.dx + t * dx, a.dy + t * dy);
    return (p - proj).distance;
  }

  List<Map<String, dynamic>> splitLineIntoGridSegments(Map<String, dynamic> shape) {
    final p1 = shape['start'] as Offset;
    final p2 = shape['end'] as Offset;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final distance = (p1 - p2).distance;
    final int segments = max(1, (distance / gridSize).floor());

    List<Map<String, dynamic>> newSegments = [];
    for (int i = 0; i < segments; i++) {
      final t1 = i / segments;
      final t2 = (i + 1) / segments;
      final s1 = snapToGrid(Offset(p1.dx + dx * t1, p1.dy + dy * t1));
      final s2 = snapToGrid(Offset(p1.dx + dx * t2, p1.dy + dy * t2));
      if (s1 != s2) {
        newSegments.add({'type': 'line', 'start': s1, 'end': s2});
      }
    }
    return newSegments;
  }

  void _handlePanStart(DragStartDetails details) {
    final point = snapToGrid(details.localPosition);
    if (widget.selectedTool == Tool.erase) {
      eraseAt(point);
    } else {
      setState(() {
        startPoint = point;
        currentPoint = point;
      });
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final point = snapToGrid(details.localPosition);
    if (widget.selectedTool == Tool.erase) {
      eraseAt(point);
    } else {
      setState(() {
        currentPoint = point;
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (startPoint == null || currentPoint == null) return;
    final start = startPoint!;
    final end = currentPoint!;
    Map<String, dynamic>? shape;

    if (widget.selectedTool == Tool.line) {
      shape = {'type': 'line', 'start': start, 'end': end};
      final segments = splitLineIntoGridSegments(shape);
      for (final seg in segments) {
        widget.onShapeDrawn(seg);
      }
    } else if (widget.selectedTool == Tool.rectangle) {
      final rect = Rect.fromPoints(start, end);
      final topLeft = snapToGrid(rect.topLeft);
      final topRight = snapToGrid(rect.topRight);
      final bottomLeft = snapToGrid(rect.bottomLeft);
      final bottomRight = snapToGrid(rect.bottomRight);

      final lines = [
        {'type': 'line', 'start': topLeft, 'end': topRight},
        {'type': 'line', 'start': topRight, 'end': bottomRight},
        {'type': 'line', 'start': bottomRight, 'end': bottomLeft},
        {'type': 'line', 'start': bottomLeft, 'end': topLeft},
      ];

      for (final line in lines) {
        final segs = splitLineIntoGridSegments(line);
        for (final seg in segs) {
          widget.onShapeDrawn(seg);
        }
      }
    } else if (widget.selectedTool == Tool.circle) {
      final radius = (start - end).distance / 2;
      final center = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      );

      shape = {
        'type': 'circle',
        'center': snapToGrid(center),
        'radius': radius,
      };

      widget.onShapeDrawn(shape);
    }

    setState(() {
      startPoint = null;
      currentPoint = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: CustomPaint(
        painter: _GridAndShapePainter(
          shapes: widget.shapes,
          currentStart: startPoint,
          currentEnd: currentPoint,
          tool: widget.selectedTool,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _GridAndShapePainter extends CustomPainter {
  final List<Map<String, dynamic>> shapes;
  final Offset? currentStart;
  final Offset? currentEnd;
  final Tool tool;

  _GridAndShapePainter({
    required this.shapes,
    required this.currentStart,
    required this.currentEnd,
    required this.tool,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    for (var shape in shapes) {
      if (shape['type'] == 'line') {
        canvas.drawLine(shape['start'], shape['end'], paint);
      } else if (shape['type'] == 'circle') {
        canvas.drawCircle(shape['center'], shape['radius'], paint);
      }
    }

    // Draw current shape preview
    if (currentStart != null && currentEnd != null) {
      final previewPaint = Paint()
        ..color = Colors.greenAccent
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      if (tool == Tool.line) {
        canvas.drawLine(currentStart!, currentEnd!, previewPaint);
      } else if (tool == Tool.rectangle) {
        canvas.drawRect(Rect.fromPoints(currentStart!, currentEnd!), previewPaint);
      } else if (tool == Tool.circle) {
        final radius = (currentStart! - currentEnd!).distance / 2;
        final center = Offset(
          (currentStart!.dx + currentEnd!.dx) / 2,
          (currentStart!.dy + currentEnd!.dy) / 2,
        );
        canvas.drawCircle(center, radius, previewPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridAndShapePainter oldDelegate) {
    return true;
  }
}
