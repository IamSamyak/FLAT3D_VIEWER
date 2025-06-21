import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flat3d_viewer/widgets/drawing_board.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final GlobalKey<DrawingBoardState> drawingBoardKey = GlobalKey();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.light,
          background: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: false,
      ),
      home: DrawingBoard(key: drawingBoardKey),
    ),
  );
}
