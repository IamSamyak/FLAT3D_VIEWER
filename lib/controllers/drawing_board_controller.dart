import 'package:flutter/material.dart';
import 'package:flat3d_viewer/models/tool_mode.dart';
import 'package:flat3d_viewer/models/view_mode.dart';
import 'package:flat3d_viewer/models/line_segment.dart';
import 'package:flat3d_viewer/models/line.dart';
import 'package:flat3d_viewer/models/rectangle_shape.dart';
import 'package:flat3d_viewer/models/circle_shape.dart';
import 'package:flat3d_viewer/models/ellipse_shape.dart';
import 'package:flat3d_viewer/models/ellipse_arc.dart';
import 'package:flat3d_viewer/models/arc.dart';
import 'package:flat3d_viewer/models/drawing_layer.dart';
import 'package:flat3d_viewer/services/drawing_service.dart';
import 'package:flat3d_viewer/services/drawing_constraint_helper.dart';

class DrawingBoardController {
  final double gridSpacing;
  final double toolsPanelWidth;

  final Map<ViewMode, List<DrawingLayer>> viewLayers;

  int activeLayerIndex = 0;
  ToolMode toolMode = ToolMode.draw;

  ViewMode _currentView = ViewMode.top;
  ViewMode get currentView => _currentView;

  Offset? startPoint;
  Offset? eraserPosition;
  Offset panOffset = Offset.zero;
  Offset? lastPanPosition;

  Line? pendingLine;
  RectangleShape? pendingRectangle;
  CircleShape? pendingCircle;
  EllipseShape? pendingEllipse;
  EllipseArc? pendingEllipseArc;
  Arc? pendingArc;

  late final DrawingService drawingService;

  DrawingBoardController({
    required this.gridSpacing,
    required this.toolsPanelWidth,
    required List<DrawingLayer> initialLayers,
  }) : viewLayers = {
         for (var view in ViewMode.values) view: [...initialLayers],
       } {
    drawingService = DrawingService(
      gridSpacing: gridSpacing,
      toolsPanelWidth: toolsPanelWidth,
    );
  }

  List<DrawingLayer> get currentLayers => viewLayers[_currentView]!;

  DrawingLayer get activeLayer => currentLayers[activeLayerIndex];

  Offset _defaultTopOrigin(Size size) => Offset(size.width - 40.0, 40.0);

  Offset _getAxisOrigin(Size size) {
    return _defaultTopOrigin(size); // Always use top origin as the base
  }

  void setViewMode(ViewMode newView, Size canvasSize) {
    if (_currentView == newView) return;

    final padding = 40.0;
    final topOrigin = _defaultTopOrigin(canvasSize); // Always the same
    Offset newViewOrigin;

    switch (newView) {
      case ViewMode.front:
        newViewOrigin = Offset(
          canvasSize.width - padding,
          canvasSize.height - padding,
        );
        break;
      case ViewMode.top:
        newViewOrigin = topOrigin;
        break;
      default:
        newViewOrigin = Offset(canvasSize.width / 2, canvasSize.height / 2);
        break;
    }

    panOffset = newViewOrigin - topOrigin; // Always use top as base
    _currentView = newView;
  }

  bool _isPointAllowed(Offset point, Size size) {
    final axisOrigin = _getAxisOrigin(size) + panOffset;
    return isPointAllowedInViewMode(point, axisOrigin, _currentView);
  }

  void startDraw(Offset point, Size size) {
    final snapped = drawingService.snapToGrid(point - panOffset);
    if (!_isPointAllowed(snapped + panOffset, size)) return;
    if (activeLayer.isLocked) return;

    switch (toolMode) {
      case ToolMode.erase:
        handleErase(snapped);
        break;
      case ToolMode.line:
        pendingLine = Line(start: snapped, end: snapped);
        break;
      case ToolMode.rectangle:
        pendingRectangle = RectangleShape(
          topLeft: snapped,
          bottomRight: snapped,
        );
        break;
      case ToolMode.circle:
        pendingCircle = CircleShape(center: snapped, radius: 0);
        break;
      case ToolMode.ellipse:
        pendingEllipse = EllipseShape(topLeft: snapped, bottomRight: snapped);
        break;
      case ToolMode.pan:
        lastPanPosition = point;
        break;
      default:
        startPoint = snapped;
    }
  }

  void updateDraw(Offset point, Size size, VoidCallback onUpdate) {
    if (toolMode == ToolMode.pan && lastPanPosition != null) {
      final delta = point - lastPanPosition!;
      final tentativeOffset = panOffset + delta;
      panOffset = Offset(
        (tentativeOffset.dx / gridSpacing).round() * gridSpacing,
        (tentativeOffset.dy / gridSpacing).round() * gridSpacing,
      );
      lastPanPosition = point;
      onUpdate();
      return;
    }

    final snapped = drawingService.snapToGrid(point - panOffset);
    if (!_isPointAllowed(snapped + panOffset, size)) return;
    if (activeLayer.isLocked) return;

    switch (toolMode) {
      case ToolMode.erase:
        eraserPosition = point;
        handleErase(snapped);
        onUpdate();
        break;
      case ToolMode.line:
        if (pendingLine != null) {
          pendingLine = Line(start: pendingLine!.start, end: snapped);
          onUpdate();
        }
        break;
      case ToolMode.rectangle:
        if (pendingRectangle != null) {
          pendingRectangle = RectangleShape(
            topLeft: pendingRectangle!.topLeft,
            bottomRight: snapped,
          );
          onUpdate();
        }
        break;
      case ToolMode.circle:
        if (pendingCircle != null) {
          final rawDistance = (snapped - pendingCircle!.center).distance;
          final unitCount = (rawDistance / gridSpacing).round();
          final quantizedRadius = unitCount * gridSpacing;
          pendingCircle = CircleShape(
            center: pendingCircle!.center,
            radius: quantizedRadius,
          );
          onUpdate();
        }
        break;
      case ToolMode.ellipse:
        if (pendingEllipse != null) {
          pendingEllipse = EllipseShape(
            topLeft: pendingEllipse!.topLeft,
            bottomRight: snapped,
          );
          onUpdate();
        }
        break;
      default:
        if (startPoint != null) {
          activeLayer.lines.add(LineSegment(start: startPoint!, end: snapped));
          startPoint = snapped;
          onUpdate();
        }
    }
  }

  void endDraw(VoidCallback onUpdate) {
    if (toolMode == ToolMode.pan) {
      lastPanPosition = null;
      return;
    }

    if (activeLayer.isLocked) return;

    switch (toolMode) {
      case ToolMode.line:
        if (pendingLine != null) {
          activeLayer.lines.add(
            LineSegment(start: pendingLine!.start, end: pendingLine!.end),
          );
          pendingLine = null;
          onUpdate();
        }
        break;
      case ToolMode.rectangle:
        if (pendingRectangle != null) {
          activeLayer.rectangles.add(pendingRectangle!);
          pendingRectangle = null;
          onUpdate();
        }
        break;
      case ToolMode.circle:
        if (pendingCircle != null) {
          activeLayer.circles.add(pendingCircle!);
          pendingCircle = null;
          onUpdate();
        }
        break;
      case ToolMode.ellipse:
        if (pendingEllipse != null) {
          activeLayer.ellipses.add(pendingEllipse!);
          pendingEllipse = null;
          onUpdate();
        }
        break;
      default:
        startPoint = null;
    }
  }

  void handleErase(Offset erasePoint) {
    const double radius = 15;

    final updatedLines = <LineSegment>[];
    final remainingRectangles = <RectangleShape>[];
    final remainingCircles = <CircleShape>[];
    final updatedArcs = <Arc>[];
    final remainingEllipses = <EllipseShape>[];
    final updatedEllipseArcs = <EllipseArc>[];

    for (var ellipse in activeLayer.ellipses) {
      if (drawingService.ellipseIntersectsEraser(
        ellipse.topLeft,
        ellipse.bottomRight,
        erasePoint,
        radius,
      )) {
        final center = Offset(
          (ellipse.topLeft.dx + ellipse.bottomRight.dx) / 2,
          (ellipse.topLeft.dy + ellipse.bottomRight.dy) / 2,
        );
        final radiusX = (ellipse.bottomRight.dx - ellipse.topLeft.dx).abs() / 2;
        final radiusY = (ellipse.bottomRight.dy - ellipse.topLeft.dy).abs() / 2;
        final arcs = drawingService.splitEllipseIntoArcs(
          center,
          radiusX,
          radiusY,
          erasePoint,
          radius,
        );
        updatedEllipseArcs.addAll(arcs);
      } else {
        remainingEllipses.add(ellipse);
      }
    }

    for (var arc in activeLayer.ellipseArcs) {
      if (drawingService.ellipseArcIntersectsEraser(arc, erasePoint, radius)) {
        final splitArcs = drawingService.splitEllipseArcIntoArcs(
          arc,
          erasePoint,
          radius,
        );
        updatedEllipseArcs.addAll(splitArcs);
      } else {
        updatedEllipseArcs.add(arc);
      }
    }

    for (var line in activeLayer.lines) {
      if (drawingService.lineIntersectsCircle(
        line.start,
        line.end,
        erasePoint,
        radius,
      )) {
        updatedLines.addAll(
          drawingService.splitLineAroundCircle(
            line.start,
            line.end,
            erasePoint,
            radius,
          ),
        );
      } else {
        updatedLines.add(line);
      }
    }

    for (var rect in activeLayer.rectangles) {
      final topLeft = rect.topLeft;
      final bottomRight = rect.bottomRight;
      final topRight = Offset(bottomRight.dx, topLeft.dy);
      final bottomLeft = Offset(topLeft.dx, bottomRight.dy);

      final edges = [
        LineSegment(start: topLeft, end: topRight),
        LineSegment(start: topRight, end: bottomRight),
        LineSegment(start: bottomRight, end: bottomLeft),
        LineSegment(start: bottomLeft, end: topLeft),
      ];

      bool erased = false;
      for (var edge in edges) {
        if (drawingService.lineIntersectsCircle(
          edge.start,
          edge.end,
          erasePoint,
          radius,
        )) {
          updatedLines.addAll(
            drawingService.splitLineAroundCircle(
              edge.start,
              edge.end,
              erasePoint,
              radius,
            ),
          );
          erased = true;
        } else {
          updatedLines.add(edge);
        }
      }

      if (!erased) remainingRectangles.add(rect);
    }

    for (var circle in activeLayer.circles) {
      if (drawingService.circleIntersectsEraser(
        circle.center,
        circle.radius,
        erasePoint,
        radius,
      )) {
        final arcs = drawingService.splitCircleIntoArcs(
          circle.center,
          circle.radius,
          erasePoint,
          radius,
        );
        updatedArcs.addAll(arcs);
      } else {
        remainingCircles.add(circle);
      }
    }

    for (var arc in activeLayer.arcs) {
      if (drawingService.arcIntersectsEraser(arc, erasePoint, radius)) {
        final splitArcs = drawingService.splitArcIntoArcs(
          arc,
          erasePoint,
          radius,
        );
        updatedArcs.addAll(splitArcs);
      } else {
        updatedArcs.add(arc);
      }
    }

    activeLayer.lines = updatedLines;
    activeLayer.rectangles = remainingRectangles;
    activeLayer.circles = remainingCircles;
    activeLayer.ellipses = remainingEllipses;
    activeLayer.arcs = updatedArcs;
    activeLayer.ellipseArcs = updatedEllipseArcs;
  }
}
