import 'dart:math';
import 'dart:ui';

import 'package:game_board/src/two_dimensions_map/map_controller.dart';
import 'package:game_board/src/two_dimensions_map/map_properties.dart';

class OnTapProcessor {
  final MapProperties mapProperties;
  final MapControllerImpl controller;

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
    final zoomOxDelta = (controller.screenSize.width - (controller.screenSize.width / controller.zoom)) / 2;
    final zoomOyDelta = (controller.screenSize.height - (controller.screenSize.height / controller.zoom)) / 2;
    print('localPosition: ${localPosition.dx},${localPosition.dy} , controller.zoom: ${controller.zoom} '
        ', zoomOxDelta: $zoomOxDelta');
    final gp = Offset(
      localPosition.dx / controller.zoom -
          (mapProperties.offsetOx + controller.fullMapController.value.dx) +
          zoomOxDelta,
      localPosition.dy / controller.zoom -
          (mapProperties.offsetOy + controller.fullMapController.value.dy) +
          zoomOyDelta,
    );

    print('ox clicked: ${(gp.dx >= 0 ? gp.dx : (gp.dx - mapProperties.tileWidth)) / mapProperties.tileWidth}');

    var x = (gp.dx >= 0 ? gp.dx : (gp.dx - mapProperties.tileWidth)) ~/ mapProperties.tileWidth;
    var y = (gp.dy >= 0 ? gp.dy : (gp.dy - mapProperties.tileHeight)) ~/ mapProperties.tileHeight;

    if (x < 0) {
      x += mapProperties.tilesOx;
    }
    if (y < 0) {
      y += mapProperties.tilesOy;
    }
    if (x >= mapProperties.tilesOx) {
      x -= mapProperties.tilesOx;
    }
    if (y >= mapProperties.tilesOy) {
      y -= mapProperties.tilesOy;
    }
    return Point(x, y);
  }
}
