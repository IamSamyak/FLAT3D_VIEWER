import 'package:flutter/material.dart';

class DrawingToolBar extends StatelessWidget {
  final bool erasing;
  final VoidCallback onDrawSelected;
  final VoidCallback onEraseSelected;
  final VoidCallback onLineSelected;
  final VoidCallback onRectangleSelected;
  final VoidCallback onCircleSelected;
  final VoidCallback onEllipseSelected;
  final double width;

  const DrawingToolBar({
    super.key,
    required this.erasing,
    required this.onDrawSelected,
    required this.onEraseSelected,
    required this.onLineSelected,
    required this.onRectangleSelected,
    required this.onCircleSelected,
    required this.onEllipseSelected,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: !erasing ? Colors.blue : Colors.black,
            onPressed: onDrawSelected,
            tooltip: 'Free Draw',
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            color: erasing ? Colors.red : Colors.black,
            onPressed: onEraseSelected,
            tooltip: 'Erase',
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: onLineSelected,
            tooltip: 'Line Tool',
          ),
          IconButton(
            icon: const Icon(Icons.crop_square),
            onPressed: onRectangleSelected,
            tooltip: 'Rectangle Tool',
          ),
          IconButton(
            icon: const Icon(Icons.circle),
            onPressed: onCircleSelected,
            tooltip: 'Circle Tool',
          ),
          IconButton(
            icon: const Icon(Icons.roundabout_left),
            onPressed: onEllipseSelected,
            tooltip: 'Ellipse Tool',
          ),
        ],
      ),
    );
  }
}