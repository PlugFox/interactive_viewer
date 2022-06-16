import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:game_board/src/two_dimensions_map/map_properties.dart';

/// Контроллер отслеживающий отступ камеры для доски
class ThrottledOffsetController {
  final ThrottledController renderController;
  final ThrottledController fullMapController;

  ThrottledOffsetController({
    required Offset initialValue,
    required MapProperties mapProperties,
  })  : renderController = ThrottledController(
          initialValue: initialValue,
          oxLength: mapProperties.tilesOxDisplayed * mapProperties.tileWidth,
          oyLength: mapProperties.tilesOyDisplayed * mapProperties.tileHeight,
          tileWidth: mapProperties.tileWidth,
        ),
        fullMapController = ThrottledController(
          initialValue: initialValue,
          oxLength: mapProperties.tilesOx * mapProperties.tileWidth,
          oyLength: mapProperties.tilesOy * mapProperties.tileHeight,
          tileWidth: mapProperties.tileWidth,
        );

  void translate(double x, double y) {
    renderController.update(renderController.translateCircular(x, y));
    fullMapController.update(fullMapController.translateCircular(x, y));
  }
}

/// Value Notifier
class ThrottledController with ChangeNotifier implements ValueListenable<Offset> {
  final double oxLength;
  final double oyLength;
  final double tileWidth;

  final double tileWidthHalf;

  final Offset tilesOffset;
  final Offset pixelOffset;

  int rotationsOx = 0;
  int rotationsOy = 0;

  ThrottledController({
    required Offset initialValue,
    required this.oxLength,
    required this.oyLength,
    required this.tileWidth,
    this.tilesOffset = const Offset(0, 0),
  })  : _value = initialValue.translate(tilesOffset.dx * tileWidth, 0),
        tileWidthHalf = 0, //tileWidth / 2,
        pixelOffset = Offset(tilesOffset.dx * tileWidth, 0);

  /// Обновляет текущее значение
  bool update(Offset value) {
    _value = value;
    notifyListeners();
    return true;
  }

  Offset translateCircular(double x, double y) {
    var newValue = value.translate(x, y);

    if (newValue.dx > (oxLength + tileWidthHalf - pixelOffset.dx)) {
      newValue = newValue.translate(-oxLength, 0);
      rotationsOx--;
    }
    if (newValue.dx < (-oxLength - tileWidthHalf - pixelOffset.dx)) {
      newValue = newValue.translate(oxLength, 0);
      rotationsOx++;
    }
    if (newValue.dy > oyLength) {
      newValue = newValue.translate(0, -oyLength);
      rotationsOy--;
    }
    if (newValue.dy < -oyLength) {
      newValue = newValue.translate(0, oyLength);
      rotationsOy++;
    }

    return newValue;
  }

  void reset({double dx = 0, double dy = 0}) {
    _value = Offset(dx, dy);
    notifyListeners();
  }

  @override
  Offset get value => _value;
  Offset _value;
}
