import 'dart:math';
import 'dart:ui';

import 'map_controller.dart';
import 'map_properties.dart';

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
    //print('localPosition: ${localPosition.dx},${localPosition.dy} , controller.zoom: ${controller.zoom} ');
    final gp = Offset(
      localPosition.dx / controller.zoom -
          (mapProperties.offsetOx + controller.fullMapController.value.dx) +
          zoomOxDelta,
      localPosition.dy / controller.zoom -
          (mapProperties.offsetOy + controller.fullMapController.value.dy) +
          zoomOyDelta,
    );

    var x = (gp.dx >= 0 ? gp.dx : (gp.dx - mapProperties.tileWidth)) ~/ mapProperties.tileWidth;
    var y = (gp.dy >= 0 ? gp.dy : (gp.dy - mapProperties.tileHeight)) ~/ mapProperties.tileHeight;

    while (x < 0) {
      x += mapProperties.tilesOx;
    }
    while (y < 0) {
      y += mapProperties.tilesOy;
    }
    while (x >= mapProperties.tilesOx) {
      x -= mapProperties.tilesOx;
    }
    while (y >= mapProperties.tilesOy) {
      y -= mapProperties.tilesOy;
    }
    return Point(x, y);
  }
}
