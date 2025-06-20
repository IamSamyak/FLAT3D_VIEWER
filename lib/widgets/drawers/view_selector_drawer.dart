import 'package:flat3d_viewer/models/view_mode.dart';
import 'package:flutter/material.dart';

class ViewSelectorDrawer extends StatelessWidget {
  final ViewMode currentView;
  final ValueChanged<ViewMode> onViewSelected;
  final bool isDrawerOpen;
  final VoidCallback onToggleDrawer;

  const ViewSelectorDrawer({
    super.key,
    required this.currentView,
    required this.onViewSelected,
    required this.isDrawerOpen,
    required this.onToggleDrawer,
  });

  static const List<MapEntry<ViewMode, String>> viewLabels = [
    MapEntry(ViewMode.top, 'Top'),
    MapEntry(ViewMode.side, 'Side'),
    MapEntry(ViewMode.front, 'Front'),
  ];

  static const Map<ViewMode, IconData> viewIcons = {
    ViewMode.top: Icons.keyboard_arrow_up,
    ViewMode.side: Icons.view_week,
    ViewMode.front: Icons.crop_16_9,
  };

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: MediaQuery.of(context).size.width / 2 - 100,
      child: Column(
        children: [
          // Button showing selected view
          GestureDetector(
            onTap: onToggleDrawer,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(viewIcons[currentView], color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    viewLabels.firstWhere((e) => e.key == currentView).value,
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Options list with all three views
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isDrawerOpen ? 60 : 0,
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(top: 8),
            padding: isDrawerOpen ? const EdgeInsets.symmetric(horizontal: 8) : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: isDrawerOpen
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: viewLabels.map((entry) {
                      final isSelected = entry.key == currentView;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: InkWell(
                          onTap: () => onViewSelected(entry.key),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  viewIcons[entry.key],
                                  color: isSelected ? Colors.blue : Colors.grey.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  entry.value,
                                  style: TextStyle(
                                    color: isSelected ? Colors.blue : Colors.grey.shade800,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
