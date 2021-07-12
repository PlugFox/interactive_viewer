// ignore_for_file: prefer_mixin

import 'dart:async';
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
                  builder: (context, constraints) => _BoardLayout(
                    offsetController: _controller,
                    boardSize: constraints.biggest,
                    cellSize: widget.size,
                  ),
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

/// Лэйаут доски
@immutable
class _BoardLayout extends StatefulWidget {
  /// Контроллер положения камеры
  final _ThrottledOffsetController offsetController;

  /// Размер клеточки
  final Size cellSize;

  /// Размер доски
  final Size boardSize;

  const _BoardLayout({
    required this.offsetController,
    required this.cellSize,
    required this.boardSize,
    Key? key,
  }) : super(key: key);

  @override
  State<_BoardLayout> createState() => _BoardLayoutState();
}

class _BoardLayoutState extends State<_BoardLayout> {
  /// Стрим контроллер уведомляющий об изменении по X, от 0 до width
  /// (значение в нем указывает о номере изменившейся колонки)
  final StreamController<int> _rebuildControllerCol =
      StreamController<int>.broadcast();

  /// Предидущий отступ колонок
  int oldColOffset = 0;

  /// Количество колонок умещающихся на экране
  int width = 0;

  /// Стрим контроллер уведомляющий об изменении по Y, от 0 до height
  /// (значение в нем указывает о номере изменившейся строки)
  final StreamController<int> _rebuildControllerRow =
      StreamController<int>.broadcast();

  /// Предидущий отступ строк
  int oldRowOffset = 0;

  /// Количество строк умещающихся на экране
  int height = 0;

  /// Вызывается при изменении положения камеры
  /// Вычисляет столбцы нуждающиеся в перестроении
  /// Для перестроения столбца вызывайте [_rebuildControllerCol.add]
  /// с номером столбца (от 0 до width)
  void _rebuildX() {
    final newColOffset =
        -(widget.offsetController.value.dx / widget.cellSize.width).ceil();
    if (newColOffset != oldColOffset) {
      print('!!!!!!! COL: $oldColOffset => $newColOffset');
      _rebuildControllerCol.add(0);

      /// TODO: обновлять определенную столбец
    }
    /*
    for (var x = 0; x < width; x++) {
      // Перемещение столбца
      if (newColOffset.isNegative) {
        final xBoardOffset =
            math.min(((width + newColOffset - x) / width).ceil() - 1, 0);
      } else {
        final xBoardOffset = math.max(((newColOffset - x) / width).ceil(), 0);
      }
    }
    */
    oldColOffset = newColOffset;
  }

  /// Вызывается при изменении положения камеры
  /// Вычисляет столбцы нуждающиеся в перестроении
  /// Для перестроения столбца вызывайте [_rebuildControllerRow.add]
  /// с номером строки (от 0 до height)
  void _rebuildY() {
    final newRowOffset =
        -(widget.offsetController.value.dy / widget.cellSize.height).ceil();
    if (newRowOffset != oldRowOffset) {
      print('!!!!!!! ROW: $oldRowOffset => $newRowOffset');
      _rebuildControllerRow.add(0);

      /// TODO: обновлять определенную строку
    }
    /*
    for (var y = 0; y < height; y++) {
      // Перемещение строки
      if (newRowOffset.isNegative) {
        final yBoardOffset =
            math.min(((height + newRowOffset - y) / height).ceil() - 1, 0);
      } else {
        final yBoardOffset = math.max(((newRowOffset - y) / height).ceil(), 0);
      }
    }
    */
    oldRowOffset = newRowOffset;
  }

  //region Lifecycle
  @override
  void initState() {
    super.initState();
    _evalSizeTileCount();
    widget.offsetController..addListener(_rebuildX)..addListener(_rebuildY);
  }

  @override
  void didUpdateWidget(_BoardLayout oldWidget) {
    _evalSizeTileCount();
    super.didUpdateWidget(oldWidget);
  }

  // Расчитываю сколько клеточек может
  // поместиться на экране по каждой оси
  // с небольшим запасом
  void _evalSizeTileCount() {
    width = (widget.boardSize.width / widget.cellSize.width).ceil() + 1;
    height = (widget.boardSize.height / widget.cellSize.height).ceil() + 1;
  }

  @override
  void dispose() {
    _rebuildControllerCol.close();
    _rebuildControllerRow.close();
    widget.offsetController
      ..removeListener(_rebuildX)
      ..removeListener(_rebuildY);
    super.dispose();
  }
  //endregion

  @override
  Widget build(BuildContext context) => Flow(
        delegate: _BoardFlowDelegate(
          width,
          height,
          widget.cellSize,
          widget.offsetController,
        ),
        children: _buildTiles(
          width,
          height,
        ).toList(growable: false),
      );

  /// TODO: необходимо перестраивать клетки
  /// возвращая не исходные координаты виджетов
  /// , а результирующие координаты клетки [colOffset], [rowOffset]
  Iterable<Widget> _buildTiles(
    int width,
    int height,
  ) sync* {
    final board = context.findAncestorWidgetOfExactType<_Board>()!;
    final builder = board.builder;
    final cellSize = board.size;
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        yield SizedBox.fromSize(
          size: cellSize,
          child: StreamBuilder<int>(
            stream: _rebuildControllerCol.stream.where((v) => v == x),
            builder: (context, _) => StreamBuilder<int>(
              stream: _rebuildControllerRow.stream.where((v) => v == y),
              builder: (context, _) => builder(x, y),
            ),
          ),
        );
      }
    }
  }
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
        xBoardOffset =
            math.min(((width + colOffset - x) / width).ceil() - 1, 0);
      } else {
        xBoardOffset = math.max(((colOffset - x) / width).ceil(), 0);
      }
      for (var y = 0; y < height; y++) {
        // Перемещение строки
        if (rowOffset.isNegative) {
          yBoardOffset =
              math.min(((height + rowOffset - y) / height).ceil() - 1, 0);
        } else {
          yBoardOffset = math.max(((rowOffset - y) / height).ceil(), 0);
        }

        // Отрисуем клетку #i
        context.paintChild(
          i,
          opacity: 1,
          transform: Matrix4.translationValues(
            listenable.value.dx + (x + xBoardOffset * width) * size.width,
            listenable.value.dy + (y + yBoardOffset * height) * size.height,
            0,
          ),
        );

        i++;
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

/// Контроллер отслеживающий отступ камеры для доски
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

/// Value Notifier с троттлингом под заданое количество FPS
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
