import 'package:flutter/material.dart';

class Arc {
  final Offset center;
  final double radius;
  final double startAngle; // Radians
  final double sweepAngle; // Radians

  Arc({
    required this.center,
    required this.radius,
    required this.startAngle,
    required this.sweepAngle,
  });
}
