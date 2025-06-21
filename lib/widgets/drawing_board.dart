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

  @override
  void initState() {
    super.initState();

    final initialLayers = [DrawingLayer(name: 'Layer 1')];
    controller = DrawingBoardController(
      gridSpacing: gridSpacing,
      toolsPanelWidth: toolsPanelWidth,
      initialLayers: initialLayers,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLayers = controller.currentLayers;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            children: [
              GestureDetector(
                onPanStart: (details) =>
                    controller.startDraw(details.localPosition, size),
                onPanUpdate: (details) =>
                    controller.updateDraw(details.localPosition, size, () => setState(() {})),
                onPanEnd: (_) =>
                    controller.endDraw(() => setState(() {})),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomPaint(
                        painter: DrawingPainter(
                          layers: currentLayers,
                          gridSpacing: gridSpacing,
                          showEraser: controller.toolMode == ToolMode.erase,
                          eraserPosition: controller.eraserPosition,
                          eraserRadius: 15,
                          pendingLine: controller.pendingLine,
                          pendingRectangle: controller.pendingRectangle,
                          pendingCircle: controller.pendingCircle,
                          pendingEllipse: controller.pendingEllipse,
                          pendingArc: controller.pendingArc,
                          pendingEllipseArc: controller.pendingEllipseArc,
                          currentView: controller.currentView,
                          panOffset: controller.panOffset,
                        ),
                        child: Container(),
                      ),
                    ),
                  ],
                ),
              ),

              /// Tool / Layer / View drawers
              DrawingBoardDrawers(
                layers: currentLayers,
                activeLayerIndex: controller.activeLayerIndex,
                isToolDrawerOpen: _isToolDrawerOpen,
                isLayerDrawerOpen: _isLayerDrawerOpen,
                isViewDrawerOpen: _isViewDrawerOpen,
                currentTool: controller.toolMode,
                currentView: controller.currentView,

                onLayerSelected: (index) {
                  setState(() {
                    controller.activeLayerIndex = index;
                  });
                },

                onToggleLayerDrawer: () {
                  setState(() {
                    _isLayerDrawerOpen = !_isLayerDrawerOpen;
                  });
                },

                onAddLayer: () {
                  setState(() {
                    final current = controller.currentLayers;
                    current.add(DrawingLayer(name: 'Layer \${current.length + 1}'));
                    controller.activeLayerIndex = current.length - 1;
                  });
                },

                onDeleteLayer: (index) {
                  final current = controller.currentLayers;
                  if (current.length > 1) {
                    setState(() {
                      current.removeAt(index);
                      controller.activeLayerIndex =
                          controller.activeLayerIndex.clamp(0, current.length - 1);
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
                  setState(() {
                    controller.currentLayers[index].isLocked =
                        !controller.currentLayers[index].isLocked;
                  });
                },

                onToolSelected: (mode) {
                  setState(() {
                    controller.toolMode = mode;
                  });
                },

                onToggleToolDrawer: () {
                  setState(() {
                    _isToolDrawerOpen = !_isToolDrawerOpen;
                  });
                },

                onViewSelected: (view) {
                  setState(() {
                    controller.currentView = view;
                  });
                },

                onToggleViewDrawer: () {
                  setState(() {
                    _isViewDrawerOpen = !_isViewDrawerOpen;
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
