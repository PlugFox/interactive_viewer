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

  TilesBuilder({
    required this.mapProperties,
    required this.coordinateBuilder,
    required this.offsetController,
  });

  void close() {
    pointController.close();
  }

  /// top-left
  Point<int> coordinate = const Point<int>(0, 0);

  void rebuildPosition() {
    final cameraOffset = offsetController.value;
    final currentTopCoord = Point(-1 * (cameraOffset.dx + mapProperties.tileWidth - 1) ~/ mapProperties.tileWidth,
        -1 * (cameraOffset.dy + mapProperties.tileHeight - 1) ~/ mapProperties.tileHeight);

    if (coordinate != currentTopCoord) {
      coordinate = currentTopCoord;
    }

    //return _storedWidgets;
  }

  Iterable<Widget> buildTiles() sync* {
    for (var x = 0; x < mapProperties.tilesOx; x++) {
      for (var y = 0; y < mapProperties.tilesOy; y++) {
        yield coordinateBuilder(x, y);
      }
    }
  }
}
