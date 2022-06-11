import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:game_board/src/two_dimensions_map/tiles_builder.dart';

typedef CoordinateBuilder = Widget Function(int x, int y);

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
    final tilesCoordinate = tilesBuilder.coordinate;

    final cellsOx = tilesBuilder.mapProperties.tilesOx;
    final cellsOy = tilesBuilder.mapProperties.tilesOy;

    for (var x = 0; x < cellsOx; x++) {
      for (var y = 0; y < cellsOy; y++) {
        late Offset offset;

        if (x >= (tilesCoordinate.x + tilesBuilder.mapProperties.tilesOx)) {
          final newX = x - cellsOx;
          final ox = newX * tilesBuilder.mapProperties.tileWidth;

          offset = Offset(
            ox,
            y * tilesBuilder.mapProperties.tileHeight +
                tilesBuilder.coordinate.y * tilesBuilder.mapProperties.tileHeight,
          );
        } else {
          offset = Offset(
            x * tilesBuilder.mapProperties.tileWidth,
            y * tilesBuilder.mapProperties.tileHeight,
          );
        }

        // Отрисуем клетку #i
        context.paintChild(
          i,
          opacity: 1,
          transform: Matrix4.translationValues(
            offset.dx + listenable.value.dx,
            offset.dy + listenable.value.dy,
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
