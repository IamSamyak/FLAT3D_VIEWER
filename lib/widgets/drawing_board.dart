import 'package:flutter/material.dart';
import 'package:flat3d_viewer/models/tool_mode.dart';
import 'package:flat3d_viewer/models/drawing_layer.dart';
import 'package:flat3d_viewer/widgets/painters/drawing_painter.dart';
import 'package:flat3d_viewer/widgets/drawers/drawing_board_drawers.dart';
import 'package:flat3d_viewer/controllers/drawing_board_controller.dart';

class DrawingBoard extends StatefulWidget {
  const DrawingBoard({super.key});

  @override
  _DrawingBoardState createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  final double gridSpacing = 20.0;
  final double toolsPanelWidth = 100.0;

  bool _isLayerDrawerOpen = false;
  bool _isToolDrawerOpen = false;
  bool _isViewDrawerOpen = false;

  late DrawingBoardController controller;
  final List<DrawingLayer> _layers = [DrawingLayer(name: 'Layer 1')];

  @override
  void initState() {
    super.initState();
    controller = DrawingBoardController(
      gridSpacing: gridSpacing,
      toolsPanelWidth: toolsPanelWidth,
      layers: _layers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (details) => controller.startDraw(details.localPosition),
            onPanUpdate: (details) => controller.updateDraw(details.localPosition, () => setState(() {})),
            onPanEnd: (_) => controller.endDraw(() => setState(() {})),
            child: Row(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: DrawingPainter(
                      layers: _layers,
                      gridSpacing: gridSpacing,
                      showEraser: controller.toolMode == ToolMode.erase,
                      eraserPosition: controller.eraserPosition,
                      eraserRadius: 15,
                      pendingLine: controller.pendingLine,
                      pendingRectangle: controller.pendingRectangle,
                      pendingCircle: controller.pendingCircle,
                      pendingEllipse: controller.pendingEllipse,
                      pendingArc: controller.pendingArc,
                      currentView: controller.currentView,
                      panOffset: controller.panOffset,
                      pendingEllipseArc: controller.pendingEllipseArc,
                    ),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
          DrawingBoardDrawers(
            layers: _layers,
            activeLayerIndex: controller.activeLayerIndex,
            isToolDrawerOpen: _isToolDrawerOpen,
            isLayerDrawerOpen: _isLayerDrawerOpen,
            isViewDrawerOpen: _isViewDrawerOpen,
            currentTool: controller.toolMode,
            currentView: controller.currentView,
            onLayerSelected: (index) => setState(() => controller.activeLayerIndex = index),
            onToggleLayerDrawer: () => setState(() => _isLayerDrawerOpen = !_isLayerDrawerOpen),
            onAddLayer: () {
              setState(() {
                _layers.add(DrawingLayer(name: 'Layer \${_layers.length + 1}'));
                controller.activeLayerIndex = _layers.length - 1;
              });
            },
            onDeleteLayer: (index) {
              if (_layers.length > 1) {
                setState(() {
                  _layers.removeAt(index);
                  controller.activeLayerIndex = controller.activeLayerIndex.clamp(0, _layers.length - 1);
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("At least one layer must remain."),
                  ),
                );
              }
            },
            onToggleLayerLock: (index) {
              setState(() => _layers[index].isLocked = !_layers[index].isLocked);
            },
            onToolSelected: (mode) => setState(() => controller.toolMode = mode),
            onToggleToolDrawer: () => setState(() => _isToolDrawerOpen = !_isToolDrawerOpen),
            onViewSelected: (view) => setState(() => controller.currentView = view),
            onToggleViewDrawer: () => setState(() => _isViewDrawerOpen = !_isViewDrawerOpen),
          ),
        ],
      ),
    );
  }
}
