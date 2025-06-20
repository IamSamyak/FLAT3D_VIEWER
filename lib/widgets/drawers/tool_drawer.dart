import 'package:flutter/material.dart';
import '../../models/tool_mode.dart';

class ToolBarDrawer extends StatelessWidget {
  final ToolMode currentTool;
  final bool isDrawerOpen;
  final ValueChanged<ToolMode> onToolSelected;
  final VoidCallback onToggleDrawer;

  const ToolBarDrawer({
    super.key,
    required this.currentTool,
    required this.isDrawerOpen,
    required this.onToolSelected,
    required this.onToggleDrawer,
  });

  static const double drawerWidth = 160;

  final List<MapEntry<ToolMode, String>> toolLabels = const [
    MapEntry(ToolMode.draw, 'Draw'),
    MapEntry(ToolMode.erase, 'Erase'),
    MapEntry(ToolMode.line, 'Line'),
    MapEntry(ToolMode.rectangle, 'Rectangle'),
    MapEntry(ToolMode.circle, 'Circle'),
    MapEntry(ToolMode.ellipse, 'Ellipse'),
  ];

  final Map<ToolMode, IconData> toolIcons = const {
    ToolMode.draw: Icons.edit,
    ToolMode.erase: Icons.remove,
    ToolMode.line: Icons.show_chart,
    ToolMode.rectangle: Icons.crop_square,
    ToolMode.circle: Icons.circle,
    ToolMode.ellipse: Icons.roundabout_left,
  };

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🧩 Right-Side Sliding Drawer
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 0,
          bottom: 0,
          right: isDrawerOpen ? 0 : -drawerWidth,
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
                    itemCount: toolLabels.length,
                    itemBuilder: (context, index) {
                      final entry = toolLabels[index];
                      final isSelected = entry.key == currentTool;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          onTap: () => onToolSelected(entry.key),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  toolIcons[entry.key],
                                  size: 24,
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.grey[700],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey[800],
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // 🎚️ Toggle Drawer Handle
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          right: isDrawerOpen ? drawerWidth : 0,
          top: MediaQuery.of(context).size.height / 2 + 40,
          child: GestureDetector(
            onTap: onToggleDrawer,
            child: Container(
              width: 36,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(
                isDrawerOpen ? Icons.chevron_right : Icons.chevron_left,
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
