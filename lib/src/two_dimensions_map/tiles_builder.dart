import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'map_controller.dart';
import 'map_flow_delegate.dart';
import 'map_properties.dart';

class TilesBuilder {
  final MapProperties mapProperties;
  final CoordinateBuilder coordinateBuilder;
  final pointController = StreamController<Point<int>>.broadcast();

  final MapControllerImpl offsetController;

  //

  //
  Map<Point<int>, Point<int>> pointMapping = {};
  Map<Point<int>, Point<int>> pointMappingAdj = {};

  Map<Point<int>, _PointWithInfo> pointFullMapping = {};

  int centerX = 0;
  TilesBuilder({
    required this.mapProperties,
    required this.coordinateBuilder,
    required this.offsetController,
  }) {
    centerX = mapProperties.tilesOxDisplayed ~/ 2;

    //_pointerPosition = _PointerPosition(0, mapProperties.tilesOxDisplayed);
    for (var x = 0; x < mapProperties.tilesOxDisplayed; x++) {
      for (var y = 0; y < mapProperties.tilesOyDisplayed; y++) {
        pointMapping[Point(x, y)] = Point(x, y);
        pointFullMapping[Point(x, y)] = _PointWithInfo(x, y, null);
      }
    }
    fullRebuildPosition();
  }

  void close() {
    pointController.close();
  }

  Offset _prevValue = const Offset(0, 0);

  Map<Point<int>, Point<int>> fullRebuildPosition() {
    final cameraPosition = offsetController.renderController.value;
    final cellsOx = mapProperties.tilesOxDisplayed;
    final cellsOy = mapProperties.tilesOyDisplayed;
    final tileWidth = mapProperties.tileWidth;
    final tileHeight = mapProperties.tileHeight;

    final rotationsOx = offsetController.renderController.rotationsOx;
    final rotationsOy = offsetController.renderController.rotationsOy;

    final lastDiff = Offset(cameraPosition.dx - _prevValue.dx, cameraPosition.dy - _prevValue.dy);
    if (lastDiff.dx.abs() < tileWidth && lastDiff.dy.abs() < tileHeight && _prevValue != const Offset(0, 0)) {
      return pointMapping;
    }
    if (_prevValue == const Offset(0, 0)) {
      _prevValue = const Offset(1, 1);
    }

    var prevX = _prevValue.dx;
    var prevY = _prevValue.dy;

    if (lastDiff.dx.abs() >= tileWidth) {
      prevX = cameraPosition.dx;
    }
    if (lastDiff.dy.abs() >= tileHeight) {
      prevY = cameraPosition.dy;
    }

    _prevValue = Offset(prevX, prevY);

    final offsetDx = (cameraPosition.dx + tileWidth - 1) / tileWidth;
    final screenOffOx = cellsOx - offsetDx;
    final offsetDy = (cameraPosition.dy + tileHeight - 1) / tileHeight;
    final screenOffOy = cellsOy - offsetDy;

    for (var x = 0; x < mapProperties.tilesOxDisplayed; x++) {
      for (var y = 0; y < mapProperties.tilesOyDisplayed; y++) {
        final thisPoint = Point(x, y);
        var ox = x; //offset for x
        var oy = y; //offset for y
        var dxMoves = 0;
        var dyMoves = 0;

        for (var i = 0; i < 2; i++) {
          if (ox > screenOffOx) {
            ox = ox - cellsOx;
            dxMoves--;
          }
          if (ox < -offsetDx) {
            ox = ox + cellsOx;
            dxMoves++;
          }
          if (oy > screenOffOy) {
            oy = y - cellsOy;
            dyMoves--;
          }
          if (oy < -offsetDy) {
            oy = y + cellsOy;
            dyMoves++;
          }
        }

        final p = Point(ox, oy);
        final adjPoint = adjustRenderPoint(p, mapProperties.tilesOxDisplayed, mapProperties.tilesOyDisplayed);

        pointMapping[thisPoint] = p;

        final oxResult = (dxMoves + rotationsOx) * mapProperties.tilesOxDisplayed + adjPoint.x;
        final oyResult = (dyMoves + rotationsOy) * mapProperties.tilesOyDisplayed + adjPoint.y;

        final adjFullPoint = adjustRenderPoint(Point(oxResult, oyResult), mapProperties.tilesOx, mapProperties.tilesOy);

        if (adjFullPoint != pointFullMapping[thisPoint]) {
          pointFullMapping[thisPoint] = _PointWithInfo(
            adjFullPoint.x,
            adjFullPoint.y,
            '$x,$y',
          );
          pointController.add(thisPoint);
        }

        pointMappingAdj[thisPoint] = adjPoint;
      }
    }

    return pointMapping;
  }

  Point<int> adjustRenderPoint(Point<int> point, int oxTiles, int oyTiles) {
    var ox = point.x;
    var oy = point.y;

    while (ox >= oxTiles) {
      ox -= oxTiles;
    }

    while (ox < 0) {
      ox += oxTiles;
    }

    while (oy >= oyTiles) {
      oy -= oyTiles;
    }

    while (oy < 0) {
      oy += oyTiles;
    }

    return Point(ox, oy);
  }

  Iterable<Widget> buildTiles(Offset cameraOffset) sync* {
    for (var x = 0; x < mapProperties.tilesOxDisplayed; x++) {
      for (var y = mapProperties.tilesOyDisplayed - 1; y >= 0; y--) {
        yield StreamBuilder(
          stream: pointController.stream.where((event) => event.x == x && event.y == y),
          builder: (context, state) {
            final truePoint = pointFullMapping[Point(x, y)] ?? _PointWithInfo(-100, -100, '');
            return coordinateBuilder(truePoint.x, truePoint.y, truePoint.info);
          },
        );
      }
    }
  }
}

class _PointWithInfo extends Point<int> {
  final String? info;

  _PointWithInfo(int x, int y, this.info) : super(x, y);
}
