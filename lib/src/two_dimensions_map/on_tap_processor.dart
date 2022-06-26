import 'dart:math';
import 'dart:ui';

import 'package:game_board/src/two_dimensions_map/map_properties.dart';
import 'package:game_board/src/two_dimensions_map/throttled_offset_controller.dart';

class OnTapProcessor {
  final MapProperties mapProperties;
  final MapController controller;

  late final double halfWidth;
  late final double halfHeight;

  OnTapProcessor({
    required this.mapProperties,
    required this.controller,
  }) {
    halfWidth = mapProperties.tileWidth / 2;
    halfHeight = mapProperties.tileHeight / 2;
  }

  Point<int> getPointTapped(Offset localPosition) {
    //print('localPosition: ${localPosition.dx},${localPosition.dy}');
    final gp = Offset(
      localPosition.dx * controller.scale - (mapProperties.offsetOx + controller.fullMapController.value.dx),
      localPosition.dy * controller.scale - (mapProperties.offsetOy + controller.fullMapController.value.dy),
    );

    var x = (gp.dx >= 0 ? gp.dx : (gp.dx - mapProperties.tileWidth)) ~/ mapProperties.tileWidth;
    var y = (gp.dy >= 0 ? gp.dy : (gp.dy - mapProperties.tileHeight)) ~/ mapProperties.tileHeight;

    if (x < 0) {
      x += mapProperties.tilesOx;
    }
    if (y < 0) {
      y += mapProperties.tilesOy;
    }
    if (x >= mapProperties.tilesOx){
      x -= mapProperties.tilesOx;
    }
    if (y >= mapProperties.tilesOy){
      y -= mapProperties.tilesOy;
    }
    return Point(x, y);
  }
}