import 'package:flat3d_viewer/models/tool.dart';
import 'package:flutter/material.dart';

class LeftToolbar extends StatelessWidget {
  final VoidCallback onBack;
  final Tool selectedTool;
  final Function(Tool) onToolSelected;

  const LeftToolbar({
    super.key,
    required this.onBack,
    required this.selectedTool,
    required this.onToolSelected,
  });

  Widget _buildToolButton({
    required IconData icon,
    required String tooltip,
    required Tool tool,
    required BuildContext context,
  }) {
    final bool isSelected = selectedTool == tool;
    return IconButton(
      icon: Icon(icon),
      color: isSelected ? Colors.blueAccent : Colors.white,
      tooltip: tooltip,
      onPressed: () {
        if (isSelected) {
          onToolSelected(Tool.none); // Deselect if already selected
        } else {
          onToolSelected(tool); // Select new tool
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: Colors.grey[900],
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              tooltip: 'Back',
              onPressed: onBack,
            ),
            const Divider(color: Colors.white24),
            _buildToolButton(
              icon: Icons.crop_square_outlined,
              tooltip: 'Rectangle',
              tool: Tool.rectangle,
              context: context,
            ),
            _buildToolButton(
              icon: Icons.circle_outlined,
              tooltip: 'Circle',
              tool: Tool.circle,
              context: context,
            ),
            _buildToolButton(
              icon: Icons.show_chart,
              tooltip: 'Line',
              tool: Tool.line,
              context: context,
            ),
            _buildToolButton(
              icon: Icons.select_all,
              tooltip: 'Select',
              tool: Tool.select,
              context: context,
            ),
            _buildToolButton(
              icon: Icons.edit,
              tooltip: 'Edit',
              tool: Tool.edit,
              context: context,
            ),
            _buildToolButton(
              icon: Icons.backspace_outlined,
              tooltip: 'Eraser',
              tool: Tool.erase,
              context: context,
            ),
          ],
        ),
      ),
    );
  }
}
