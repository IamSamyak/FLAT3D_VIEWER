import 'dart:math';
import 'package:flutter/material.dart';

class RadialToolSelector extends StatefulWidget {
  final Function(String) onToolSelected;

  const RadialToolSelector({super.key, required this.onToolSelected});

  @override
  State<RadialToolSelector> createState() => _RadialToolSelectorState();
}

class _RadialToolSelectorState extends State<RadialToolSelector> {
  bool isOpen = false;

  final List<_ToolOption> tools = [
    _ToolOption(icon: Icons.edit, name: 'draw'),
    _ToolOption(icon: Icons.remove, name: 'erase'),
    _ToolOption(icon: Icons.show_chart, name: 'line'),
    _ToolOption(icon: Icons.crop_square, name: 'rectangle'),
    _ToolOption(icon: Icons.circle, name: 'circle'),
    _ToolOption(icon: Icons.roundabout_left, name: 'ellipse'),
  ];

  void _selectTool(String toolName) {
    widget.onToolSelected(toolName);
    setState(() => isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      right: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isOpen)
            ...List.generate(tools.length, (index) {
              final angle = (2 * pi / tools.length) * index;
              final dx = cos(angle) * 80;
              final dy = sin(angle) * 80;
              return Positioned(
                left: dx + 30,
                top: dy + 30,
                child: FloatingActionButton.small(
                  heroTag: null,
                  onPressed: () => _selectTool(tools[index].name),
                  child: Icon(tools[index].icon, size: 20),
                ),
              );
            }),
          FloatingActionButton(
            heroTag: 'radial-menu',
            onPressed: () => setState(() => isOpen = !isOpen),
            child: const Icon(Icons.menu),
          ),
        ],
      ),
    );
  }
}

class _ToolOption {
  final IconData icon;
  final String name;

  _ToolOption({required this.icon, required this.name});
}
