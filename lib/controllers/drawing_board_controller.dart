import 'package:flutter/material.dart';
import 'package:flat3d_viewer/models/tool_mode.dart';
import 'package:flat3d_viewer/models/view_mode.dart';
import 'package:flat3d_viewer/models/line_segment.dart';
import 'package:flat3d_viewer/models/line.dart';
import 'package:flat3d_viewer/models/rectangle_shape.dart';
import 'package:flat3d_viewer/models/circle_shape.dart';
import 'package:flat3d_viewer/models/ellipse_shape.dart';
import 'package:flat3d_viewer/models/drawing_layer.dart';
import 'package:flat3d_viewer/services/drawing_service.dart';

class DrawingBoardController extends ChangeNotifier {
  final double gridSpacing;
  final double toolsPanelWidth;

  final DrawingService drawingService;
  final List<DrawingLayer> layers = [DrawingLayer(name: 'Layer 1')];
  int activeLayerIndex = 0;

  ToolMode toolMode = ToolMode.draw;
  ViewMode currentView = ViewMode.top;

  bool isLayerDrawerOpen = false;
  bool isToolDrawerOpen = false;
  bool isViewDrawerOpen = false;

  Offset? startPoint;
  Offset? eraserPosition;
  Offset panOffset = Offset.zero;
  Offset? lastPanPosition;

  Line? pendingLine;
  RectangleShape? pendingRectangle;
  CircleShape? pendingCircle;
  EllipseShape? pendingEllipse;

  DrawingLayer get activeLayer => layers[activeLayerIndex];

  DrawingBoardController({
    required this.gridSpacing,
    required this.toolsPanelWidth,
  }) : drawingService = DrawingService(gridSpacing: gridSpacing, toolsPanelWidth: toolsPanelWidth);

  void startDraw(Offset point) {
    final snapped = drawingService.snapToGrid(point - panOffset);
    if (activeLayer.isLocked) return;

    switch (toolMode) {
      case ToolMode.erase:
        _handleErase(snapped);
        break;
      case ToolMode.line:
        pendingLine = Line(start: snapped, end: snapped);
        break;
      case ToolMode.rectangle:
        pendingRectangle = RectangleShape(topLeft: snapped, bottomRight: snapped);
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

  void updateDraw(Offset point) {
    if (toolMode == ToolMode.pan) {
      if (lastPanPosition != null) {
        final delta = point - lastPanPosition!;
        final tentativeOffset = panOffset + delta;
        panOffset = Offset(
          (tentativeOffset.dx / gridSpacing).round() * gridSpacing,
          (tentativeOffset.dy / gridSpacing).round() * gridSpacing,
        );
        lastPanPosition = point;
        notifyListeners();
      }
      return;
    }

    final snapped = drawingService.snapToGrid(point - panOffset);
    if (activeLayer.isLocked) return;

    switch (toolMode) {
      case ToolMode.erase:
        eraserPosition = point;
        _handleErase(snapped);
        break;
      case ToolMode.line:
        if (pendingLine != null) {
          pendingLine = Line(start: pendingLine!.start, end: snapped);
        }
        break;
      case ToolMode.rectangle:
        if (pendingRectangle != null) {
          pendingRectangle = RectangleShape(topLeft: pendingRectangle!.topLeft, bottomRight: snapped);
        }
        break;
      case ToolMode.circle:
        if (pendingCircle != null) {
          final radius = (snapped - pendingCircle!.center).distance;
          pendingCircle = CircleShape(center: pendingCircle!.center, radius: radius);
        }
        break;
      case ToolMode.ellipse:
        if (pendingEllipse != null) {
          pendingEllipse = EllipseShape(topLeft: pendingEllipse!.topLeft, bottomRight: snapped);
        }
        break;
      default:
        if (startPoint != null) {
          activeLayer.lines.add(LineSegment(start: startPoint!, end: snapped));
          startPoint = snapped;
        }
    }
    notifyListeners();
  }

  void endDraw() {
    if (toolMode == ToolMode.pan) {
      lastPanPosition = null;
      return;
    }

    if (activeLayer.isLocked) return;

    switch (toolMode) {
      case ToolMode.line:
        if (pendingLine != null) {
          activeLayer.lines.add(LineSegment(start: pendingLine!.start, end: pendingLine!.end));
          pendingLine = null;
        }
        break;
      case ToolMode.rectangle:
        if (pendingRectangle != null) {
          activeLayer.rectangles.add(pendingRectangle!);
          pendingRectangle = null;
        }
        break;
      case ToolMode.circle:
        if (pendingCircle != null) {
          activeLayer.circles.add(pendingCircle!);
          pendingCircle = null;
        }
        break;
      case ToolMode.ellipse:
        if (pendingEllipse != null) {
          activeLayer.ellipses.add(pendingEllipse!);
          pendingEllipse = null;
        }
        break;
      default:
        break;
    }
    startPoint = null;
    notifyListeners();
  }

  void _handleErase(Offset point) {
    const double radius = 15;
    List<LineSegment> updatedLines = [];

    for (var line in activeLayer.lines) {
      if (drawingService.lineIntersectsCircle(line.start, line.end, point, radius)) {
        final split = drawingService.splitLineAroundCircle(line.start, line.end, point, radius);
        updatedLines.addAll(split);
      } else {
        updatedLines.add(line);
      }
    }

    activeLayer.lines = updatedLines;
    notifyListeners();
  }

  // Layer controls
  void addLayer() {
    layers.add(DrawingLayer(name: 'Layer ${layers.length + 1}'));
    activeLayerIndex = layers.length - 1;
    notifyListeners();
  }

  void deleteLayer(int index) {
    if (layers.length > 1) {
      layers.removeAt(index);
      activeLayerIndex = activeLayerIndex.clamp(0, layers.length - 1);
      notifyListeners();
    }
  }

  void toggleLayerLock(int index) {
    layers[index].isLocked = !layers[index].isLocked;
    notifyListeners();
  }

  // Drawer toggles
  void toggleToolDrawer() {
    isToolDrawerOpen = !isToolDrawerOpen;
    notifyListeners();
  }

  void toggleLayerDrawer() {
    isLayerDrawerOpen = !isLayerDrawerOpen;
    notifyListeners();
  }

  void toggleViewDrawer() {
    isViewDrawerOpen = !isViewDrawerOpen;
    notifyListeners();
  }

  void setToolMode(ToolMode mode) {
    toolMode = mode;
    notifyListeners();
  }

  void setViewMode(ViewMode view) {
    currentView = view;
    notifyListeners();
  }

  void selectLayer(int index) {
    activeLayerIndex = index;
    notifyListeners();
  }
}
