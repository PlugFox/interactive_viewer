import 'dart:math';
import 'dart:ui';

import 'package:game_board/src/two_dimensions_map/map_properties.dart';
import 'package:game_board/src/two_dimensions_map/throttled_offset_controller.dart';

class OnTapProcessor {
  final MapProperties mapProperties;
  final ThrottledOffsetController controller;

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

    final x = (gp.dx) ~/ mapProperties.tileWidth;
    final y = (gp.dy) ~/ mapProperties.tileHeight;

    print('getPointTapped ${gp.dx},${gp.dy} ([$x,$y])');
    return Point(x, y);
  }
}
