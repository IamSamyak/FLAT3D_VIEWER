import 'package:flutter/material.dart';
import '../models/tool_mode.dart';
import '../models/view_mode.dart';
import '../models/drawing_layer.dart';
import 'drawers/tool_drawer.dart';
import 'drawers/layer_drawer.dart';
import 'drawers/view_selector_drawer.dart';

class DrawingBoardDrawers extends StatelessWidget {
  final List<DrawingLayer> layers;
  final int activeLayerIndex;
  final bool isToolDrawerOpen;
  final bool isLayerDrawerOpen;
  final bool isViewDrawerOpen;
  final ToolMode currentTool;
  final ViewMode currentView;

  final ValueChanged<int> onLayerSelected;
  final VoidCallback onToggleLayerDrawer;
  final VoidCallback onAddLayer;
  final ValueChanged<int> onDeleteLayer;
  final ValueChanged<int> onToggleLayerLock;

  final ValueChanged<ToolMode> onToolSelected;
  final VoidCallback onToggleToolDrawer;

  final ValueChanged<ViewMode> onViewSelected;
  final VoidCallback onToggleViewDrawer;

  const DrawingBoardDrawers({
    super.key,
    required this.layers,
    required this.activeLayerIndex,
    required this.isToolDrawerOpen,
    required this.isLayerDrawerOpen,
    required this.isViewDrawerOpen,
    required this.currentTool,
    required this.currentView,
    required this.onLayerSelected,
    required this.onToggleLayerDrawer,
    required this.onAddLayer,
    required this.onDeleteLayer,
    required this.onToggleLayerLock,
    required this.onToolSelected,
    required this.onToggleToolDrawer,
    required this.onViewSelected,
    required this.onToggleViewDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer Drawer
        LayerDrawer(
          layers: layers,
          activeLayerIndex: activeLayerIndex,
          isDrawerOpen: isLayerDrawerOpen,
          onLayerSelected: onLayerSelected,
          onToggleDrawer: onToggleLayerDrawer,
          onAddLayer: onAddLayer,
          onDeleteLayer: onDeleteLayer,
          onToggleLock: onToggleLayerLock,
        ),

        // Tool Drawer
        ToolBarDrawer(
          currentTool: currentTool,
          isDrawerOpen: isToolDrawerOpen,
          onToggleDrawer: onToggleToolDrawer,
          onToolSelected: onToolSelected,
        ),

        // View Selector Drawer
        ViewSelectorDrawer(
          currentView: currentView,
          isDrawerOpen: isViewDrawerOpen,
          onToggleDrawer: onToggleViewDrawer,
          onViewSelected: onViewSelected,
        ),
      ],
    );
  }
}
