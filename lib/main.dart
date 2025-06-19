import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/drawing_board.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    const MaterialApp(
      home: DrawingBoard(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
