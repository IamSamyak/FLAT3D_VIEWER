// file: widgets/layer_drawer.dart
import 'package:flutter/material.dart';
import '../models/drawing_layer.dart';

class LayerDrawer extends StatelessWidget {
  final List<DrawingLayer> layers;
  final int activeLayerIndex;
  final bool isDrawerOpen;
  final Function(int) onLayerSelected;
  final VoidCallback onToggleDrawer;
  final VoidCallback onAddLayer;
  final Function(int) onDeleteLayer;
  final Function(int) onToggleLock;

  const LayerDrawer({
    super.key,
    required this.layers,
    required this.activeLayerIndex,
    required this.isDrawerOpen,
    required this.onLayerSelected,
    required this.onToggleDrawer,
    required this.onAddLayer,
    required this.onDeleteLayer,
    required this.onToggleLock,
  });

  @override
  Widget build(BuildContext context) {
    const drawerWidth = 200.0;

    return Stack(
      children: [
        // Sliding Drawer
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 0,
          bottom: 0,
          left: isDrawerOpen ? 0 : -drawerWidth,
          child: Container(
            width: drawerWidth,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F3F3),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: layers.length,
                    itemBuilder: (context, index) {
                      final layer = layers[index];
                      final isSelected = index == activeLayerIndex;

                      return GestureDetector(
                        onTap: () => onLayerSelected(index),
                        child: Container(
                          color:
                              isSelected
                                  ? Colors.blue[100]
                                  : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  layer.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  layer.isLocked ? Icons.lock : Icons.lock_open,
                                  size: 20,
                                ),
                                onPressed: () => onToggleLock(index),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                onPressed: () => onDeleteLayer(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton(
                    onPressed: onAddLayer,
                    mini: true,
                    tooltip: 'Add Layer',
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Updated Animated Toggle Button
        // Polished Toggle Button with consistent border radius and lowered position
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          // top: MediaQuery.of(context).size.height / 2 + 35,
          bottom: MediaQuery.of(context).size.height / 2 + 35,
          left: isDrawerOpen ? drawerWidth : 0,
          child: GestureDetector(
            onTap: onToggleDrawer,
            child: Container(
              width: 36,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(
                isDrawerOpen ? Icons.chevron_left : Icons.chevron_right,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
