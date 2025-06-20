import 'package:flat3d_viewer/models/view_mode.dart';
import 'package:flutter/material.dart';

class ViewSelectorDrawer extends StatelessWidget {
  final ViewMode currentView;
  final bool isDrawerOpen;
  final ValueChanged<ViewMode> onViewSelected;
  final VoidCallback onToggleDrawer;

  const ViewSelectorDrawer({
    super.key,
    required this.currentView,
    required this.isDrawerOpen,
    required this.onViewSelected,
    required this.onToggleDrawer,
  });

  static const double drawerHeight = 360;

  final List<MapEntry<ViewMode, String>> viewLabels = const [
    MapEntry(ViewMode.top, 'Top'),
    MapEntry(ViewMode.side, 'Side'),
    MapEntry(ViewMode.front, 'Front'),
  ];

  final Map<ViewMode, IconData> viewIcons = const {
    ViewMode.top: Icons.keyboard_arrow_up,
    ViewMode.side: Icons.view_week,
    ViewMode.front: Icons.crop_16_9,
  };

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🔽 Top-Down Drawer
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: 0,
          right: 0,
          top: isDrawerOpen ? 0 : -drawerHeight,
          child: Container(
            height: drawerHeight,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F3F3),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Column(
              children: viewLabels.map((entry) {
                final isSelected = entry.key == currentView;
                return InkWell(
                  onTap: () => onViewSelected(entry.key),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          viewIcons[entry.key],
                          size: 24,
                          color:
                              isSelected ? Colors.blue : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.value,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade800,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // 🔼 Drawer Toggle Button (Top Center)
        Positioned(
          top: isDrawerOpen ? drawerHeight : 0,
          left: MediaQuery.of(context).size.width / 2 - 18,
          child: GestureDetector(
            onTap: onToggleDrawer,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(
                isDrawerOpen ? Icons.expand_less : Icons.expand_more,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
