import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:game_board/src/two_dimensions_map/map_properties.dart';

typedef ClickCallback = void Function(int x, int y);

/// Контроллер отслеживающий отступ камеры для доски
class MapController {
  final ThrottledController renderController;
  final ThrottledController fullMapController;
  final MapProperties mapProperties;

  Size? _screenSize;
  Point<int> _lastCenterPoint = const Point(0, 0);

  final Stream<Point<int>>? forceCenterPointStream;
  late final StreamSubscription? _subCenterPoint;

  final zoomController = StreamController<double>.broadcast();
  double scale = 2;

  MapController({
    required Offset initialValue,
    required this.mapProperties,
    this.forceCenterPointStream,
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
        ) {
    _subCenterPoint = forceCenterPointStream?.listen(_centerPointListener);
  }

  void setScreenSize(Size screenSize) {
    _screenSize = screenSize;
    _centerPointListener(_lastCenterPoint);
  }

  void _centerPointListener(Point<int> point) {
    _lastCenterPoint = point;
    if (_screenSize == null) {
      return;
    }
    final requiredOffset = Offset(
      -1 * point.x * mapProperties.tileWidth +
          (_screenSize!.width / 2) -
          fullMapController.value.dx -
          (mapProperties.offsetOx / 4),
      -1 * point.y * mapProperties.tileHeight +
          (_screenSize!.height / 2) -
          fullMapController.value.dy -
          (mapProperties.offsetOy / 4),
    );
    translate(requiredOffset.dx, requiredOffset.dy);
  }

  void translate(double x, double y) {
    renderController.update(renderController.translateCircular(x, y));
    fullMapController.update(fullMapController.translateCircular(x, y));
  }

  void close() {
    zoomController.close();
    _subCenterPoint?.cancel();
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
