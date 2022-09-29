import 'package:flutter/material.dart';

import 'map_controller_event.dart';

class MapControllerState {
  final double zoom;
  final Size screenSize;
  final MapEventType whatChanged;

  const MapControllerState({
    required this.screenSize,
    required this.zoom,
    this.whatChanged = MapEventType.unknown,
  });
}
