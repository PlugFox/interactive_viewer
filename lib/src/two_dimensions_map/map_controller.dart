import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_board/src/two_dimensions_map/debouncer.dart';
import 'package:game_board/src/two_dimensions_map/map_controller_event.dart';
import 'package:game_board/src/two_dimensions_map/map_controller_state.dart';
import 'package:game_board/src/two_dimensions_map/map_properties.dart';

typedef ClickCallback = void Function(int x, int y);

abstract class MapController {
  void centerToPoint(Point<int> point);

  void addEvent(MapControllerEvent event);

  void initOffsetAnimations({required TickerProvider tickerProvider});
}

/// Контроллер отслеживающий отступ камеры для доски
class MapControllerImpl implements MapController {
  final ThrottledController renderController;
  final ThrottledController fullMapController;
  final MapProperties mapProperties;

  Size _screenSize;
  Size get screenSize => _screenSize;
  Point<int> _lastCenterPoint = const Point(0, 0);

  Stream<MapControllerState> get mapStateStream => _mapStateController.stream;
  final _mapStateController = StreamController<MapControllerState>.broadcast();
  final _mapEventController = StreamController<MapControllerEvent>();
  late final StreamSubscription? _subCenterPoint;

  /// Animations:
  bool _animationsInitted = false;
  static const int msAnimation = 1000;
  final throttler = Throttler(delayMs: 50);
  Animation<Offset>? animation;
  late AnimationController _animationController;

  @override
  void initOffsetAnimations({required TickerProvider tickerProvider}) {
    if (_animationsInitted) {
      return;
    }
    _animationsInitted = true;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: msAnimation),
      vsync: tickerProvider,
    );
  }

  void _listenAnimationLocation() {
    if (animation == null) {
      return;
    }
    _internalTranslate(animation!.value.dx, animation!.value.dy);
    if (animation?.isCompleted ?? false) {
      _storedOffset = const Offset(0, 0);
    }
  }

  var _renderControllerLast = const Offset(0, 0);
  var _fullMapControllerLast = const Offset(0, 0);

  void _internalTranslate(double x, double y) {
    renderController.update(renderController.translateCircular(
      _renderControllerLast.translate(x, y),
    ));
    fullMapController.update(fullMapController.translateCircular(
      _fullMapControllerLast.translate(x, y),
    ));
  }

  var _storedOffset = const Offset(0, 0);
  static const int _scrollLimit = 400;
  void translate(double x, double y) {
    if (_animationsInitted) {
      _storedOffset = Offset(_storedOffset.dx + x, _storedOffset.dy + y);
      throttler.run(() {
        if (!(animation?.isCompleted ?? false) && ((_storedOffset.dx.abs() + _storedOffset.dy.abs()) > _scrollLimit)) {
          _storedOffset = Offset(_storedOffset.dx / 2, _storedOffset.dy / 2);
        }
        animation?.removeListener(_listenAnimationLocation);
        _animationController.reset();
        _renderControllerLast = renderController.value;
        _fullMapControllerLast = fullMapController.value;
        final tween = Tween<Offset>(begin: const Offset(0, 0), end: _storedOffset);
        animation = tween.animate(CurvedAnimation(parent: _animationController, curve: Curves.decelerate));
        animation?.addListener(_listenAnimationLocation);
        _animationController.forward();
      });
    } else {
      _internalTranslate(x, y);
    }
  }

  ///

  double zoom = 1;

  MapControllerImpl({
    required this.mapProperties,
    required Size screenSize,
  })  : renderController = ThrottledController(
          oxLength: mapProperties.tilesOxDisplayed * mapProperties.tileWidth,
          oyLength: mapProperties.tilesOyDisplayed * mapProperties.tileHeight,
          tileWidth: mapProperties.tileWidth,
        ),
        fullMapController = ThrottledController(
          oxLength: mapProperties.tilesOx * mapProperties.tileWidth,
          oyLength: mapProperties.tilesOy * mapProperties.tileHeight,
          tileWidth: mapProperties.tileWidth,
        ),
        _screenSize = screenSize {
    _subCenterPoint = _mapEventController.stream.listen(_mapEventListener);
    _setZoom(mapProperties.maxZoomIn);
  }

  void setScreenSize(Size screenSize) {
    _screenSize = screenSize;
    //renderController.reset();
    //fullMapController.reset();
    //centerToPoint(_lastCenterPoint);
  }

  void _setZoom(double scale) {
    var _scale = scale;
    if (_scale < 1) {
      _scale = 1;
    }
    if (_scale > mapProperties.maxZoomIn) {
      _scale = mapProperties.maxZoomIn;
    }

    zoom = _scale;
    _mapStateController.add(_getCurrentState(whatChanged: MapEventType.setZoom));
  }

  MapControllerState _getCurrentState({MapEventType whatChanged = MapEventType.unknown}) => MapControllerState(
        zoom: zoom,
        screenSize: _screenSize,
        whatChanged: whatChanged,
      );

  void _mapEventListener(MapControllerEvent event) {
    switch (event.eventType) {
      case MapEventType.unknown:
        break;
      case MapEventType.centerToPoint:
        centerToPoint(event.data as Point<int>);
        break;
      case MapEventType.setZoom:
        _setZoom(event.data as double);
        break;
    }
  }

  void close() {
    _subCenterPoint?.cancel();
    _mapEventController.close();
    _mapStateController.close();
  }

  @override
  void centerToPoint(Point<int> point) {
    _lastCenterPoint = point;
    final requiredOffset = Offset(
      -1 * point.x * mapProperties.tileWidth +
          (_screenSize.width / 2) -
          fullMapController.value.dx -
          (mapProperties.offsetOx / 4),
      -1 * point.y * mapProperties.tileHeight +
          (_screenSize.height / 2) -
          fullMapController.value.dy -
          (mapProperties.offsetOy / 4),
    );
    translate(requiredOffset.dx, requiredOffset.dy);
  }

  @override
  void addEvent(MapControllerEvent event) {
    _mapEventController.add(event);
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
    required this.oxLength,
    required this.oyLength,
    required this.tileWidth,
    this.tilesOffset = const Offset(0, 0),
  })  : _value = Offset(tilesOffset.dx * tileWidth, 0),
        tileWidthHalf = 0, //tileWidth / 2,
        pixelOffset = Offset(tilesOffset.dx * tileWidth, 0);

  /// Обновляет текущее значение
  bool update(Offset value) {
    _value = value;
    notifyListeners();
    return true;
  }

  Offset translateCircular(Offset offset) {
    var newValue = offset;

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
