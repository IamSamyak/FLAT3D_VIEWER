import 'package:flat3d_viewer/models/tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/left_toolbar.dart';
import '../components/orthographic_area.dart';

class CreateOrthographicViewPage extends StatefulWidget {
  const CreateOrthographicViewPage({super.key});

  @override
  State<CreateOrthographicViewPage> createState() =>
      _CreateOrthographicViewPageState();
}

class _CreateOrthographicViewPageState
    extends State<CreateOrthographicViewPage> {
  Tool selectedTool = Tool.none;
  List<Map<String, dynamic>> shapes = [];
  bool showFloatingMenu = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void onToolSelected(Tool tool) {
    setState(() {
      selectedTool = tool;
      debugPrint("Selected Tool: $selectedTool");
    });
  }

  void addShape(Map<String, dynamic> shape) {
    setState(() {
      shapes.add(shape);
    });
  }

  void addMultipleShapes(List<Map<String, dynamic>> newShapes) {
    setState(() {
      shapes.addAll(newShapes);
    });
  }

  void removeShapesMatching(bool Function(Map<String, dynamic>) condition) {
    setState(() {
      shapes.removeWhere(condition);
    });
  }

  void clearShapes() {
    setState(() {
      shapes.clear();
    });
  }

  void generate3DModelData() {
    debugPrint("Generated 3D JSON: $shapes");
  }

  void deleteAllShapes() {
    clearShapes();
    debugPrint("Cleared all shapes.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      LeftToolbar(
                        selectedTool: selectedTool,
                        onToolSelected: onToolSelected,
                        onBack: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: OrthographicDrawingArea(
                          shapes: shapes,
                          selectedTool: selectedTool,
                          onShapeDrawn: addShape,
                          onShapesUpdated: (updatedShapes) {
                            setState(() {
                              shapes = updatedShapes;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (showFloatingMenu) ...[
                    _buildMenuButton(
                      icon: Icons.delete_outline,
                      label: "Delete All",
                      onPressed: deleteAllShapes,
                    ),
                    const SizedBox(height: 8),
                    _buildMenuButton(
                      icon: Icons.save,
                      label: "Save",
                      onPressed: generate3DModelData,
                    ),
                    const SizedBox(height: 8),
                  ],
                  FloatingActionButton(
                    backgroundColor: Colors.blueAccent,
                    onPressed: () {
                      setState(() {
                        showFloatingMenu = !showFloatingMenu;
                      });
                    },
                    child: Icon(showFloatingMenu ? Icons.close : Icons.menu),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 14)),
      onPressed: onPressed,
    );
  }
}
