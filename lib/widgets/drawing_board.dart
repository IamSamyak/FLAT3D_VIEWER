// file: screens/drawing_board.dart
import 'package:flat3d_viewer/models/tool_mode.dart';
import 'package:flat3d_viewer/widgets/floating_circular_toolbar.dart';
import 'package:flat3d_viewer/widgets/layer_drawer.dart';
import 'package:flutter/material.dart';
import '../models/line_segment.dart';
import '../models/line.dart';
import '../models/rectangle_shape.dart';
import '../models/circle_shape.dart';
import '../models/ellipse_shape.dart';
import '../models/drawing_layer.dart';
import '../widgets/left_toolbar.dart';
import '../services/drawing_service.dart';
import '../widgets/drawing_painter.dart';

class DrawingBoard extends StatefulWidget {
  const DrawingBoard({super.key});

  @override
  _DrawingBoardState createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  final double gridSpacing = 20.0;
  final double toolsPanelWidth = 100.0;

  bool _isDrawerOpen = false;

  late DrawingService _drawingService;

  List<DrawingLayer> _layers = [DrawingLayer(name: 'Layer 1')];
  int _activeLayerIndex = 0;

  ToolMode _toolMode = ToolMode.draw;

  Offset? _startPoint;
  Offset? _eraserPosition;

  Line? _pendingLine;
  RectangleShape? _pendingRectangle;
  CircleShape? _pendingCircle;
  EllipseShape? _pendingEllipse;

  DrawingLayer get _activeLayer => _layers[_activeLayerIndex];

  @override
  void initState() {
    super.initState();
    _drawingService = DrawingService(
      gridSpacing: gridSpacing,
      toolsPanelWidth: toolsPanelWidth,
    );
  }

  void _startDraw(Offset point) {
    final snapped = _drawingService.snapToGrid(point);
    if (_activeLayer.isLocked) return;

    if (_toolMode == ToolMode.erase) {
      _handleErase(snapped);
    } else if (_toolMode == ToolMode.line) {
      _pendingLine = Line(start: snapped, end: snapped);
    } else if (_toolMode == ToolMode.rectangle) {
      _pendingRectangle = RectangleShape(
        topLeft: snapped,
        bottomRight: snapped,
      );
    } else if (_toolMode == ToolMode.circle) {
      _pendingCircle = CircleShape(center: snapped, radius: 0);
    } else if (_toolMode == ToolMode.ellipse) {
      _pendingEllipse = EllipseShape(topLeft: snapped, bottomRight: snapped);
    } else {
      _startPoint = snapped;
    }
  }

  void _updateDraw(Offset point) {
    final snapped = _drawingService.snapToGrid(point);
    if (_activeLayer.isLocked) return;

    if (_toolMode == ToolMode.erase) {
      setState(() {
        _eraserPosition = point;
        _handleErase(snapped);
      });
    } else if (_toolMode == ToolMode.line && _pendingLine != null) {
      setState(() {
        _pendingLine = Line(start: _pendingLine!.start, end: snapped);
      });
    } else if (_toolMode == ToolMode.rectangle && _pendingRectangle != null) {
      setState(() {
        _pendingRectangle = RectangleShape(
          topLeft: _pendingRectangle!.topLeft,
          bottomRight: snapped,
        );
      });
    } else if (_toolMode == ToolMode.circle && _pendingCircle != null) {
      setState(() {
        final radius = (snapped - _pendingCircle!.center).distance;
        _pendingCircle = CircleShape(
          center: _pendingCircle!.center,
          radius: radius,
        );
      });
    } else if (_toolMode == ToolMode.ellipse && _pendingEllipse != null) {
      setState(() {
        _pendingEllipse = EllipseShape(
          topLeft: _pendingEllipse!.topLeft,
          bottomRight: snapped,
        );
      });
    } else if (_startPoint != null) {
      setState(() {
        _activeLayer.lines.add(LineSegment(start: _startPoint!, end: snapped));
        _startPoint = snapped;
      });
    }
  }

  void _endDraw() {
    if (_activeLayer.isLocked) return;

    if (_toolMode == ToolMode.line && _pendingLine != null) {
      setState(() {
        _activeLayer.lines.add(
          LineSegment(start: _pendingLine!.start, end: _pendingLine!.end),
        );
        _pendingLine = null;
      });
    } else if (_toolMode == ToolMode.rectangle && _pendingRectangle != null) {
      setState(() {
        _activeLayer.rectangles.add(_pendingRectangle!);
        _pendingRectangle = null;
      });
    } else if (_toolMode == ToolMode.circle && _pendingCircle != null) {
      setState(() {
        _activeLayer.circles.add(_pendingCircle!);
        _pendingCircle = null;
      });
    } else if (_toolMode == ToolMode.ellipse && _pendingEllipse != null) {
      setState(() {
        _activeLayer.ellipses.add(_pendingEllipse!);
        _pendingEllipse = null;
      });
    }

    _startPoint = null;
  }

  void _handleErase(Offset erasePoint) {
    const double radius = 15;
    List<LineSegment> updatedLines = [];

    for (var line in _activeLayer.lines) {
      if (_drawingService.lineIntersectsCircle(
        line.start,
        line.end,
        erasePoint,
        radius,
      )) {
        final splitSegments = _drawingService.splitLineAroundCircle(
          line.start,
          line.end,
          erasePoint,
          radius,
        );
        updatedLines.addAll(splitSegments);
      } else {
        updatedLines.add(line);
      }
    }

    setState(() {
      _activeLayer.lines = updatedLines;
    });
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Stack(
      children: [
        // Drawing area
        GestureDetector(
          onPanStart: (details) =>
              _startDraw(_drawingService.adjustedOffset(details.localPosition)),
          onPanUpdate: (details) =>
              _updateDraw(_drawingService.adjustedOffset(details.localPosition)),
          onPanEnd: (_) => _endDraw(),
          child: Row(
            children: [
              Expanded(
                child: CustomPaint(
                  painter: DrawingPainter(
                    layers: _layers,
                    gridSpacing: gridSpacing,
                    showEraser: _toolMode == ToolMode.erase,
                    eraserPosition: _eraserPosition,
                    eraserRadius: 15,
                    pendingLine: _pendingLine,
                    pendingRectangle: _pendingRectangle,
                    pendingCircle: _pendingCircle,
                    pendingEllipse: _pendingEllipse,
                  ),
                  child: Container(),
                ),
              ),
            ],
          ),
        ),

        // Layer Drawer on the left
        LayerDrawer(
          layers: _layers,
          activeLayerIndex: _activeLayerIndex,
          isDrawerOpen: _isDrawerOpen,
          onLayerSelected: (index) => setState(() => _activeLayerIndex = index),
          onToggleDrawer: () => setState(() => _isDrawerOpen = !_isDrawerOpen),
          onAddLayer: () {
            setState(() {
              _layers.add(DrawingLayer(name: 'Layer ${_layers.length + 1}'));
              _activeLayerIndex = _layers.length - 1;
            });
          },
          onDeleteLayer: (index) {
            if (_layers.length > 1) {
              setState(() {
                _layers.removeAt(index);
                _activeLayerIndex = _activeLayerIndex.clamp(0, _layers.length - 1);
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("At least one layer must remain.")),
              );
            }
          },
          onToggleLock: (index) {
            setState(() {
              _layers[index].isLocked = !_layers[index].isLocked;
            });
          },
        ),

        // 🟢 Floating circular toolbar as a non-intrusive overlay
        Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingCircularToolbar(
                currentTool: _toolMode,
                onToolSelected: (mode) {
                  setState(() {
                    _toolMode = mode;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}
