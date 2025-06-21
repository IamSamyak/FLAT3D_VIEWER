import 'package:flutter/material.dart';
import 'package:flat3d_viewer/models/view_mode.dart';

bool isPointAllowedInViewMode(Offset point, Offset axisOrigin, ViewMode viewMode) {
  if (viewMode == ViewMode.top) {
    return point.dx <= axisOrigin.dx && point.dy >= axisOrigin.dy;
  }
  return true;
}

Offset getAxisOrigin(Size size, ViewMode viewMode) {
  const padding = 40.0;
  switch (viewMode) {
    case ViewMode.front:
      return Offset(size.width - padding, size.height - padding);
    case ViewMode.top:
      return Offset(size.width - padding, padding);
    default:
      return Offset(size.width / 2, size.height / 2);
  }
}
