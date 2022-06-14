import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Контроллер отслеживающий отступ камеры для доски
class ThrottledOffsetController extends ThrottledController<Offset> {
  final double mapOxLength;
  final double mapOyLength;

  ThrottledOffsetController({
    required Offset initialValue,
    required this.mapOxLength,
    required this.mapOyLength,
  }) : super(
          initialValue: initialValue,
        );

  void translate(double x, double y) {
    var newValue = value.translate(x, y);

    if (newValue.dx > mapOxLength) {
      newValue = newValue.translate(-mapOxLength, 0);
    }
    if (newValue.dx < -mapOxLength) {
      newValue = newValue.translate(mapOxLength, 0);
    }
    if (newValue.dy > mapOyLength) {
      newValue = newValue.translate(0, -mapOyLength);
    }
    if (newValue.dy < -mapOyLength) {
      newValue = newValue.translate(0, mapOyLength);
    }

    update(newValue);
  }

  void reset({double dx = 0, double dy = 0}) {
    _value = Offset(dx, dy);
    notifyListeners();
  }
}

/// Value Notifier
class ThrottledController<T extends Object> with ChangeNotifier implements ValueListenable<T> {
  ThrottledController({
    required T initialValue,
  }) : _value = initialValue;

  /// Обновляет текущее значение
  bool update(T value) {
    _value = value;
    notifyListeners();
    return true;
  }

  @override
  T get value => _value;
  T _value;
}
