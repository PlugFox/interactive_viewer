// ignore_for_file: prefer_mixin

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef TileBuilder = Widget Function(int x, int y);

@immutable
class Board extends StatelessWidget {
  /// Размер одного тайла
  final Size tileSize;

  /// Коллбэк вызывается для построения каждого попавшей в поле зрения
  final TileBuilder builder;

  /// Ограничение на FPS, по умолчанию - без ограничения
  final num fps;

  /// Отображать табличку с текущими координатами
  final bool debug;

  const Board({
    required this.builder,
    required this.tileSize,
    this.fps = double.infinity,
    this.debug = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _Board(
        builder: builder,
        size: tileSize,
        fps: fps,
        debug: debug,
      );
}

@immutable
class _Board extends StatefulWidget {
  final Size size;
  final TileBuilder builder;
  final num fps;
  final bool debug;

  const _Board({
    required this.builder,
    required this.size,
    required this.fps,
    required this.debug,
    Key? key,
  }) : super(key: key);

  @override
  State<_Board> createState() => _BoardState();
}

// ignore: prefer_mixin
class _BoardState extends State<_Board> {
  late _ThrottledOffsetController _controller;

  //region Lifecycle
  @override
  void initState() {
    super.initState();
    _controller = _ThrottledOffsetController(
      initialValue: const Offset(0, 0),
      fps: widget.fps,
    );
  }

  @override
  void didUpdateWidget(covariant _Board oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fps != widget.fps) {
      final oldController = _controller;
      WidgetsBinding.instance?.addPostFrameCallback(
        (_) => oldController.dispose(),
      );
      _controller = _ThrottledOffsetController(
        initialValue: _controller.value,
        fps: widget.fps,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  //endregion

  Iterable<Widget> _buildCells(int width, int height) sync* {
    final builder = widget.builder;
    final cellSize = widget.size;
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        yield SizedBox.fromSize(
          size: cellSize,
          child: builder(x, y),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onPanCancel: () => _controller.notifyListeners(),
                onPanEnd: (details) => _controller.notifyListeners(),
                onPanUpdate: (details) =>
                    _controller.translate(details.delta.dx, details.delta.dy),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Расчитываю сколько клеточек может
                    // поместиться на экране по каждой оси
                    // с небольшим запасом
                    final boardSize = constraints.biggest;
                    final cellSize = widget.size;
                    final width = (boardSize.width / cellSize.width).ceil() + 1;
                    final height =
                        (boardSize.height / cellSize.height).ceil() + 1;
                    return Flow(
                      delegate: _BoardFlowDelegate(
                        width,
                        height,
                        cellSize,
                        _controller,
                      ),
                      children: _buildCells(
                        width,
                        height,
                      ).toList(growable: false),
                    );
                  },
                ),
              ),
            ),
          ),
          if (widget.debug)
            Positioned(
              width: math.min(200, MediaQuery.of(context).size.width),
              bottom: 5,
              height: 20,
              child: ColoredBox(
                color: const Color(0xFF000000),
                child: Center(
                  child: ValueListenableBuilder<Offset>(
                    builder: (context, value, child) => Text(
                      '${value.dx.truncate()} x ${value.dy.truncate()}',
                      style: const TextStyle(
                        height: 1,
                        fontSize: 12,
                        color: Color(0xFFFFFFFF),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                    valueListenable: _controller,
                  ),
                ),
              ),
            ),
        ],
      );
}

class _BoardFlowDelegate extends FlowDelegate {
  /// Количество клеточек по ширине
  final int width;

  /// Количество клеточек по высоте
  final int height;

  /// Размер клеточки в dp
  final Size size;

  /// Контроллер со значением координат поля
  final ValueListenable<Offset> listenable;

  _BoardFlowDelegate(
    this.width,
    this.height,
    this.size,
    this.listenable,
  ) : super(repaint: listenable);

  @override
  void paintChildren(FlowPaintingContext context) {
    //final boardSize = context.size;

    // Количество целых столбцов и строк на которые съехала доска
    // по горизонтали и вертикали
    final colOffset = -(listenable.value.dx / size.width).ceil();
    final rowOffset = -(listenable.value.dy / size.height).ceil();

    // Отступы для смещения в количестве досок
    var xBoardOffset = 0;
    var yBoardOffset = 0;

    var i = 0;
    for (var x = 0; x < width; x++) {
      // Перемещение столбца
      if (colOffset.isNegative) {
        xBoardOffset = ((width + colOffset - x) / width).ceil() - 1;
        if (xBoardOffset > 0) {
          xBoardOffset = 0;
        }
      } else {
        xBoardOffset = ((colOffset - x) / width).ceil();
        if (xBoardOffset.isNegative) {
          xBoardOffset = 0;
        }
      }
      for (var y = 0; y < height; y++) {
        // Перемещение строки
        if (rowOffset.isNegative) {
          yBoardOffset = ((height + rowOffset - y) / height).ceil() - 1;
          if (yBoardOffset > 0) {
            yBoardOffset = 0;
          }
        } else {
          yBoardOffset = ((rowOffset - y) / height).ceil();
          if (yBoardOffset.isNegative) {
            yBoardOffset = 0;
          }
        }

        context.paintChild(
          i++,
          opacity: 1,
          transform: Matrix4.translationValues(
            x * size.width +
                listenable.value.dx +
                xBoardOffset * width * size.width,
            y * size.height +
                listenable.value.dy +
                yBoardOffset * height * size.height,
            0,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BoardFlowDelegate oldDelegate) =>
      !identical(listenable, oldDelegate.listenable) ||
      width != oldDelegate.width ||
      height != oldDelegate.height ||
      size != oldDelegate.size;
}

class _ThrottledOffsetController extends _ThrottledController<Offset> {
  _ThrottledOffsetController({
    required Offset initialValue,
    required num fps,
  }) : super(
          initialValue: initialValue,
          fps: fps,
        );

  void translate(double x, double y) => update(value.translate(x, y));
}

abstract class _ThrottledController<T extends Object>
    with ChangeNotifier
    implements ValueListenable<T> {
  final int _delay;
  final Stopwatch _stopwatch;

  _ThrottledController({
    required T initialValue,
    required num fps,
  })  : _value = initialValue,
        _delay = fps == double.infinity ? 0 : 1000 ~/ fps,
        _stopwatch = Stopwatch()..start();

  /// Обновляет текущее значение
  /// Если не прошло необходимое число мс - не уведомляет об изменении
  void update(T value) {
    _value = value;
    if (_stopwatch.elapsedMilliseconds < _delay) return;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    _stopwatch.reset();
    super.notifyListeners();
  }

  @override
  T get value => _value;
  T _value;
}
