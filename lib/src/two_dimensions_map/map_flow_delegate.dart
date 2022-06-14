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

    final cellsOx = tilesBuilder.mapProperties.tilesOxDisplayed;
    final cellsOy = tilesBuilder.mapProperties.tilesOyDisplayed;
    final tileWidth = tilesBuilder.mapProperties.tileWidth;
    final tileHeight = tilesBuilder.mapProperties.tileHeight;

    // screen offset:
    final offsetDx = (listenable.value.dx + tileWidth - 1) / tileWidth;
    final screenOffOx = cellsOx - offsetDx;

    final offsetDy = (listenable.value.dy + tileHeight - 1) / tileHeight;
    final screenOffOy = cellsOy - offsetDy;

    for (var x = 0; x < cellsOx; x++) {
      for (var y = 0; y < cellsOy; y++) {
        late double ox; //offset for x
        late double oy; //offset for y

        if (x > screenOffOx) {
          ox = (x - cellsOx) * tileWidth;
        } else {
          if (x < -offsetDx) {
            ox = (x + cellsOx) * tileWidth;
          } else {
            ox = x * tileWidth;
          }
        }

        if (y > screenOffOy) {
          oy = (y - cellsOy) * tileHeight;
        } else {
          if (y < -offsetDy) {
            oy = (y + cellsOy) * tileHeight;
          } else {
            oy = y * tileHeight;
          }
        }

        // Отрисуем клетку #i
        context.paintChild(
          i,
          opacity: 1,
          transform: Matrix4.translationValues(
            ox + listenable.value.dx,
            oy + listenable.value.dy,
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
