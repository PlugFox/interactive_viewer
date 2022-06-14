import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_board/src/two_dimensions_map/map_flow_delegate.dart';
import 'package:game_board/src/two_dimensions_map/map_properties.dart';
import 'package:game_board/src/two_dimensions_map/throttled_offset_controller.dart';

class TilesBuilder {
  final MapProperties mapProperties;
  final CoordinateBuilder coordinateBuilder;
  final pointController = StreamController<Point<int>>();
  final ThrottledOffsetController offsetController;

  final offsetSc = StreamController<Offset>.broadcast();

  TilesBuilder({
    required this.mapProperties,
    required this.coordinateBuilder,
    required this.offsetController,
  });

  void close() {
    pointController.close();
    offsetSc.close();
  }

  /// top-left
  Point<int> coordinate(Offset cameraOffset) => Point(
      -1 * (cameraOffset.dx + mapProperties.tileWidth - 1) ~/ mapProperties.tileWidth,
      -1 * (cameraOffset.dy + mapProperties.tileHeight - 1) ~/ mapProperties.tileHeight);

  void rebuildPosition() {
    offsetSc.add(offsetController.value);
  }

  ///TODO: actually create streambuilder that triggers only when cells are really moved

  Iterable<Widget> buildTiles(Offset cameraOffset) sync* {
    for (var x = 0; x < mapProperties.tilesOxDisplayed; x++) {
      for (var y = 0; y < mapProperties.tilesOyDisplayed; y++) {
        yield StreamBuilder(
          stream: offsetSc.stream,
          builder: (context, state) {
            final xTilesOffset = (cameraOffset.dx.toInt() - mapProperties.tileWidth + 1) ~/ mapProperties.tileWidth;
            final yTilesOffset = cameraOffset.dy.toInt() ~/ mapProperties.tileHeight;

            return coordinateBuilder(x + xTilesOffset, y + yTilesOffset);
          },
        );
      }
    }
  }
}
