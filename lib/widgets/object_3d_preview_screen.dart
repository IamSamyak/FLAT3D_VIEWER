import 'package:flutter/material.dart';
import 'package:flat3d_viewer/widgets/drawing_board.dart';
import 'package:flat3d_viewer/models/view_mode.dart';
import 'package:flat3d_viewer/services/object3d_reconstructor.dart';
import 'package:flat3d_viewer/widgets/object3d_preview.dart';

class Object3DPreviewScreen extends StatelessWidget {
  final GlobalKey<DrawingBoardState> drawingBoardKey;

  const Object3DPreviewScreen({super.key, required this.drawingBoardKey});

  @override
  Widget build(BuildContext context) {
    final controller = drawingBoardKey.currentState?.getController();

    if (controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Drawing data not available.",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    // Safely get first layer from each view
    final topLayer = controller.viewLayers[ViewMode.top]?.firstOrNull;
    final frontLayer = controller.viewLayers[ViewMode.front]?.firstOrNull;
    final sideLayer = controller.viewLayers[ViewMode.side]?.firstOrNull;

    if (topLayer == null || frontLayer == null || sideLayer == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Missing one or more view layers.",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    final object3D = Object3DReconstructor.fromViews(
      top: topLayer,
      front: frontLayer,
      side: sideLayer,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("3D Preview"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Object3DPreview(object: object3D),
        ),
      ),
    );
  }
}

extension FirstOrNullExtension<E> on List<E>? {
  E? get firstOrNull {
    final list = this;
    if (list == null || list.isEmpty) return null;
    return list.first;
  }
}
