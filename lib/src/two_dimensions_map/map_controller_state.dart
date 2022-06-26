import 'package:flutter/material.dart';
import 'package:game_board/src/two_dimensions_map/map_controller_event.dart';

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
