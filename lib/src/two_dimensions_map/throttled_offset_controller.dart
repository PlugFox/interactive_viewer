import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Контроллер отслеживающий отступ камеры для доски
class ThrottledOffsetController extends ThrottledController<Offset> {
  ThrottledOffsetController({
    required Offset initialValue,
  }) : super(
          initialValue: initialValue,
        );

  void translate(double x, double y) => update(value.translate(x, y));

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
