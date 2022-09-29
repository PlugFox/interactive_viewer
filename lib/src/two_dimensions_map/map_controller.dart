import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'debouncer.dart';
import 'map_controller_event.dart';
import 'map_controller_state.dart';
import 'map_properties.dart';

typedef ClickCallback = void Function(int x, int y);

abstract class MapController {
  void centerToPoint(Point<int> point);

  void addEvent(MapControllerEvent event);

  void initOffsetAnimations({required TickerProvider tickerProvider});

  void close();
}

/// Контроллер отслеживающий отступ камеры для доски
class MapControllerImpl implements MapController {
  final ThrottledController renderController;
  final ThrottledController fullMapController;
  final MapProperties mapProperties;

  Size _screenSize;
  Size get screenSize => _screenSize;

  Stream<MapControllerState> get mapStateStream => _mapStateController.stream;
  final _mapStateController = StreamController<MapControllerState>.broadcast();
  final _mapEventController = StreamController<MapControllerEvent>();
  late final StreamSubscription? _subCenterPoint;

  /// Animations:
  bool _animationsInitted = false;
  static const int msAnimation = 500;
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

  double _dxLast = 0;
  double _dyLast = 0;
  void _internalTranslate(double x, double y) {
    final xDiff = x - _dxLast;
    final yDiff = y - _dyLast;

    renderController.update(renderController.translateCircular(
      renderController.value.translate(xDiff, yDiff),
    ));
    fullMapController.update(fullMapController.translateCircular(
      fullMapController.value.translate(xDiff, yDiff),
    ));
    if (_animationsInitted) {
      _dxLast = x;
      _dyLast = y;
    }
  }

  bool _statusListenerAdded = false;
  var _storedOffset = const Offset(0, 0);
  static const int _scrollLimit = 400;
  void translate(double x, double y) {
    if (_animationController.isAnimating && _animationLocked) {
      return;
    }
    _animationLocked = false;
    if (_animationsInitted) {
      _animationController.duration = const Duration(milliseconds: msAnimation);
      final newX = (x.sign == _storedOffset.dx.sign) ? _storedOffset.dx + x : x;
      final newY = (y.sign == _storedOffset.dy.sign) ? _storedOffset.dy + y : y;
      _storedOffset = Offset(newX, newY);
      throttler.run(() {
        if (!(animation?.isCompleted ?? false) && ((_storedOffset.dx.abs() + _storedOffset.dy.abs()) > _scrollLimit)) {
          _storedOffset = Offset(_storedOffset.dx * 3 / 4, _storedOffset.dy * 3 / 4);
        }

        if (!_animationLocked) {
          _animateToOffset(_storedOffset);
        }
      });
    } else {
      _internalTranslate(x, y);
    }
  }

  bool _animationLocked = false;
  void _animateToOffset(Offset offset) {
    _dxLast = 0;
    _dyLast = 0;
    final tween = Tween<Offset>(begin: const Offset(0, 0), end: offset);
    animation = tween.animate(CurvedAnimation(parent: _animationController, curve: Curves.decelerate));
    if (!_statusListenerAdded) {
      _statusListenerAdded = true;
      animation?.addListener(_listenAnimationLocation);
    }
    _animationController
      ..reset()
      ..forward();
  }

  ///

  double zoom = 1;

  MapControllerImpl({
    required this.mapProperties,
    required Size screenSize,
    Point<int>? centerPoint,
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
    Future<void>.delayed(const Duration(milliseconds: 10)).then((value) {
      if (centerPoint != null) {
        jumpToPoint(centerPoint);
      }
    });
  }

  // ignore: use_setters_to_change_properties
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

  @override
  void close() {
    animation?.removeListener(_listenAnimationLocation);
    _subCenterPoint?.cancel();
    _mapEventController.close();
    _mapStateController.close();
  }

  @override
  void centerToPoint(Point<int> point) {
    final requiredOffset = _getPointCenterOffset(point);
    final maxOffset = max(requiredOffset.dx.toInt().abs() * 4, requiredOffset.dy.toInt().abs() * 4);
    _animationController.duration = Duration(milliseconds: max(maxOffset, 100));
    _animateToOffset(requiredOffset);
  }

  Offset _getPointCenterOffset(Point<int> point) {
    _animationLocked = true;
    final dxMain = -1 * point.x * mapProperties.tileWidth;
    final dxSub =
        (_screenSize.width / 2) - mapProperties.offsetOx - (mapProperties.tileWidth / 2) - fullMapController.value.dx;
    final dyMain = -1 * point.y * mapProperties.tileHeight - (mapProperties.tileHeight / 2);
    final dySub = (_screenSize.height / 2) - mapProperties.offsetOy - fullMapController.value.dy;
    final requiredOffset = Offset(
      dxMain + dxSub,
      dyMain + dySub,
    );

    return requiredOffset;
  }

  void jumpToPoint(Point<int> point) {
    final requiredOffset = _getPointCenterOffset(point);
    _dxLast = 0;
    _dyLast = 0;
    _internalTranslate(requiredOffset.dx, requiredOffset.dy);
  }

  @override
  void addEvent(MapControllerEvent event) {
    _mapEventController.add(event);
  }
}

/// Value Notifier
class ThrottledController extends ChangeNotifier implements ValueListenable<Offset> {
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

    while (newValue.dx > (oxLength + tileWidthHalf - pixelOffset.dx)) {
      newValue = newValue.translate(-oxLength, 0);
      rotationsOx--;
    }
    while (newValue.dx < (-oxLength - tileWidthHalf - pixelOffset.dx)) {
      newValue = newValue.translate(oxLength, 0);
      rotationsOx++;
    }
    while (newValue.dy > oyLength) {
      newValue = newValue.translate(0, -oyLength);
      rotationsOy--;
    }
    while (newValue.dy < -oyLength) {
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
