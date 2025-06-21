import 'package:flutter/material.dart';
import 'package:flat3d_viewer/models/view_mode.dart';

bool isPointAllowedInViewMode(
  Offset point,
  Offset axisOrigin,
  ViewMode viewMode,
) {
  switch (viewMode) {
    case ViewMode.top:
      // Allow drawing to left and down: (-X, -Y)
      return point.dx <= axisOrigin.dx && point.dy >= axisOrigin.dy;

    case ViewMode.front:
      // Allow drawing to left and up: (-X, +Y)
      return point.dx <= axisOrigin.dx && point.dy <= axisOrigin.dy;

    case ViewMode.side:
      // Allow drawing to right and up: (+X, +Y)
      return point.dx >= axisOrigin.dx && point.dy <= axisOrigin.dy;

    default:
      return true; // No restriction
  }
}
