import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'tiles_builder.dart';

typedef CoordinateBuilder = Widget Function(int x, int y, String? debug);

class MapFlowDelegate extends FlowDelegate {
  final TilesBuilder tilesBuilder;

  /// Контроллер со значением координат поля
  final ValueListenable<Offset> listenable;

  const MapFlowDelegate({
    required this.tilesBuilder,
    required this.listenable,
  }) : super(repaint: listenable);

  @override
  void paintChildren(FlowPaintingContext context) {
    var i = 0;

    final cellsOx = tilesBuilder.mapProperties.tilesOxDisplayed;
    final cellsOy = tilesBuilder.mapProperties.tilesOyDisplayed;
    final tileWidth = tilesBuilder.mapProperties.tileWidth;
    final tileHeight = tilesBuilder.mapProperties.tileHeight;

    final pointsMapping = tilesBuilder.fullRebuildPosition();

    for (var x = 0; x < cellsOx; x++) {
      for (var y = cellsOy - 1; y >= 0; y--) {
        final point = pointsMapping[Point(x, y)];

        // Отрисуем клетку #i
        context.paintChild(
          i,
          opacity: 1,
          transform: Matrix4.translationValues(
            (point?.x ?? 0) * tileWidth + listenable.value.dx + tilesBuilder.mapProperties.offsetOx,
            (point?.y ?? 0) * tileHeight + listenable.value.dy + tilesBuilder.mapProperties.offsetOy,
            0,
          ),
        );

        i++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant MapFlowDelegate oldDelegate) => !identical(listenable, oldDelegate.listenable);
}
