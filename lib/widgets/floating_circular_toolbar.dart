import 'dart:math';
import 'package:flutter/material.dart';
import '../models/tool_mode.dart';

class FloatingCircularToolbar extends StatefulWidget {
  final ToolMode currentTool;
  final ValueChanged<ToolMode> onToolSelected;

  const FloatingCircularToolbar({
    super.key,
    required this.currentTool,
    required this.onToolSelected,
  });

  @override
  State<FloatingCircularToolbar> createState() => _FloatingCircularToolbarState();
}

class _FloatingCircularToolbarState extends State<FloatingCircularToolbar>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  final double radius = 100;

  final List<MapEntry<ToolMode, IconData>> tools = const [
    MapEntry(ToolMode.draw, Icons.edit),
    MapEntry(ToolMode.erase, Icons.remove),
    MapEntry(ToolMode.line, Icons.show_chart),
    MapEntry(ToolMode.rectangle, Icons.crop_square),
    MapEntry(ToolMode.circle, Icons.circle),
    MapEntry(ToolMode.ellipse, Icons.roundabout_left),
  ];

  final List<double> anglesInDegrees = [120, 90, 60, 30, 0, 330];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: SizedBox.expand(
        child: Stack(
          children: [
            // Tool buttons
            ...List.generate(tools.length, (index) {
              final angleInRadians = anglesInDegrees[index] * (pi / 180);
              final dx = radius * cos(angleInRadians);
              final dy = radius * sin(angleInRadians);

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                right: _isOpen ? dx + 20 : 20,
                bottom: _isOpen ? dy + 20 : 20,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isOpen ? 1 : 0,
                  child: RawMaterialButton(
                    onPressed: () {
                      widget.onToolSelected(tools[index].key);
                      setState(() => _isOpen = false);
                    },
                    elevation: 4.0,
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    shape: const CircleBorder(),
                    fillColor: widget.currentTool == tools[index].key
                        ? Colors.blue
                        : Colors.grey,
                    child: Icon(
                      tools[index].value,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),

            // Main toggle button
            Positioned(
              right: 20,
              bottom: 20,
              child: RawMaterialButton(
                onPressed: () => setState(() => _isOpen = !_isOpen),
                elevation: 6.0,
                constraints: const BoxConstraints.tightFor(
                  width: 56,
                  height: 56,
                ),
                shape: const CircleBorder(),
                fillColor: Colors.white,
                child: Icon(
                  _isOpen ? Icons.close : Icons.menu,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
