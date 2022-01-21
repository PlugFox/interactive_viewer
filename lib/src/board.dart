// ignore_for_file: prefer_mixin

import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef TileBuilder = Widget Function(int x, int y);

@immutable
class Board extends StatelessWidget {
  /// Размер всей "доски" в тайлах по горизонтали и вертикали. По умолчанию - бесконечно ( Size(0,0) )
  /// Size(0,10) - соответствует бесконечной оси Ox и 10 клеток по Oy
  final Size fullBoardSize;

  /// Зациклен ли скролл, по-умолчанию - нет (пустота за пределами)
  /// При True - значения повторяются (как будто глобус)
  final bool isCycled;

  /// Размер одного тайла
  final Size tileSize;

  /// Коллбэк вызывается для построения каждого попавшей в поле зрения
  final TileBuilder builder;

  /// Ограничение на FPS, по умолчанию - без ограничения
  final num fps;

  /// Отображать табличку с текущими координатами
  final bool debug;

  ///Начальная угловая (левый верхний угол) координата по X
  final int startCoordOx;

  ///Начальная угловая (левый верхний угол) координата по Y
  final int startCoordOy;

  const Board({
    required this.builder,
    required this.tileSize,
    this.fullBoardSize = const Size(0, 0),
    this.isCycled = false,
    this.fps = double.infinity,
    this.debug = false,
    this.startCoordOx = 0,
    this.startCoordOy = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _Board(
        builder: builder,
        size: tileSize,
        fps: fps,
        debug: debug,
        startCoordOx: startCoordOx,
        startCoordOy: startCoordOy,
        fullBoardSize: fullBoardSize,
        isCycled: isCycled,
      );
}

Point<int> getCellsOffset(Offset cameraOffset, Size tileSize) {
  print('cell size:' + tileSize.toString());
  //сам рассчет производить относительно текущей позиции камеры и ближайшей к ней клетке (Если левая, то надо ставить угловую позицию, если правая - то плюсовую)
  // прибавить по половине (отцентровать относительно точки) и посмотреть куда ближе камера:
  final offsetTilesX = -1 * ((cameraOffset.dx + tileSize.width) / tileSize.width).ceil();
  final offsetTilesY = -1 * ((cameraOffset.dy + tileSize.height) / tileSize.height).ceil();
  return Point<int>(offsetTilesX, offsetTilesY);
}

@immutable
class _Board extends StatefulWidget {
  final Size size;
  final TileBuilder builder;
  final num fps;
  final bool debug;

  ///Начальная угловая (левый верхний угол) координата по X
  final int startCoordOx;

  ///Начальная угловая (левый верхний угол) координата по Y
  final int startCoordOy;

  /// Размер всей "доски" в тайлах по горизонтали и вертикали. По умолчанию - бесконечно
  final Size fullBoardSize;

  /// Зациклен ли скролл, по-умолчанию - нет
  final bool isCycled;

  const _Board({
    required this.builder,
    required this.size,
    required this.fps,
    required this.debug,
    this.fullBoardSize = const Size(0, 0),
    this.isCycled = false,
    this.startCoordOx = 0,
    this.startCoordOy = 0,
    Key? key,
  }) : super(key: key);

  @override
  State<_Board> createState() => _BoardState();
}

class _BoardState extends State<_Board> {
  late _ThrottledOffsetController _controller;
  Size currentSize = const Size(100, 100);

  //region Lifecycle
  @override
  void initState() {
    super.initState();
    currentSize = widget.size;
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
                /*
                onPanCancel: () => _controller.notifyListeners(),
                onPanEnd: (details) => _controller.notifyListeners(),
                onPanUpdate: (details) {
                  print('details.delta.distanceSquared:' + details.globalPosition.distanceSquared.toString());

                  _controller.translate(details.delta.dx, details.delta.dy);
                },

                 */
                onScaleUpdate: (scaleInfo) {
                  //print('scaleInfo.focalPointDelta: ' + scaleInfo.focalPointDelta.toString());
                  _controller.translate(scaleInfo.focalPointDelta.dx, scaleInfo.focalPointDelta.dy);
                  if (scaleInfo.scale > 0.5 && scaleInfo.scale < 2 && scaleInfo.scale != 1) {
                    setState(() {
                      currentSize = Size(widget.size.width * scaleInfo.scale, widget.size.height * scaleInfo.scale);
                    });
                  }
                },
                child: LayoutBuilder(
                  builder: (context, constraints) => _BoardLayout(
                    offsetController: _controller,
                    boardSize: constraints.biggest,
                    cellSize: currentSize,
                    startCoordOx: widget.startCoordOx,
                    startCoordOy: widget.startCoordOy,
                    fullBoardSize: widget.fullBoardSize,
                    isCycled: widget.isCycled,
                  ),
                ),
              ),
            ),
          ),
          if (widget.debug)
            Positioned(
              width: math.min(200, MediaQuery.of(context).size.width),
              bottom: 5,
              height: 40,
              child: ColoredBox(
                color: const Color(0xFF000000),
                child: Center(
                  child: ValueListenableBuilder<Offset>(
                    builder: (context, value, child) => Text(
                      '${value.dx.truncate()} x ${value.dy.truncate()} \n ${getCellsOffset(value, widget.size)}}',
                      style: const TextStyle(
                        height: 1,
                        fontSize: 12,
                        color: Color(0xFFFFFFFF),
                      ),
                      textAlign: TextAlign.center,
                      //maxLines: 2,
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

  final int startCoordOx;
  final int startCoordOy;

  /// Размер всей "доски" в тайлах по горизонтали и вертикали. По умолчанию - бесконечно
  final Size fullBoardSize;

  /// Зациклен ли скролл, по-умолчанию - нет
  final bool isCycled;

  const _BoardLayout({
    required this.offsetController,
    required this.cellSize,
    required this.boardSize,
    required this.fullBoardSize,
    required this.isCycled,
    this.startCoordOx = 0,
    this.startCoordOy = 0,
    Key? key,
  }) : super(key: key);

  @override
  State<_BoardLayout> createState() => _BoardLayoutState();
}

class _BoardLayoutState extends State<_BoardLayout> {
  /// Стрим контроллер уведомляющий об изменении по X, от 0 до width
  /// (значение в нем указывает о номере изменившейся колонки)
  final StreamController<int> _rebuildControllerCol = StreamController<int>.broadcast();

  Offset startOffset = Offset(0, 0);

  /// Предидущий отступ колонок
  int oldColOffset = 0;

  /// Количество колонок умещающихся на экране
  int width = 0;

  /// Стрим контроллер уведомляющий об изменении по Y, от 0 до height
  /// (значение в нем указывает о номере изменившейся строки)
  final StreamController<int> _rebuildControllerRow = StreamController<int>.broadcast();

  /// Предыдущий отступ строк
  int oldRowOffset = 0;

  /// Количество строк умещающихся на экране
  int height = 0;

  CellMapper cellMapper = CellMapper(width: 0, height: 0);

  /// Вызывается при изменении положения камеры
  /// Вычисляет столбцы нуждающиеся в перестроении
  /// Для перестроения столбца вызывайте [_rebuildControllerCol.add]
  /// с номером столбца (от 0 до width)
  void _rebuildX() {
    final newColOffset = -(widget.offsetController.value.dx / widget.cellSize.width).ceil();
    if (newColOffset == oldColOffset) {
      return;
    }
    print('!!!!!!! COL: $oldColOffset => $newColOffset');

    /*
    //тоже самое что и:
    while (newCell < 0) {
      newCell += width;
    }
    */
    var newCell = newColOffset.abs();
    if (newColOffset < 0) {
      newCell = width - newCell;
    }

    final complexPoint = getCellsOffset(widget.offsetController.value, widget.cellSize);
    final offsetCells = complexPoint;
    final mult = ((offsetCells.x) / width).ceil();
    if ((oldColOffset - newColOffset) < 0) {
      //листаем вправо
      newCell = (width - 2 + newCell) % width;
      var newX = mult * width + newCell;
      newX += widget.startCoordOx;
      newX = cellMapper.normalizeOx(newX);

      cellMapper.mapOx[newCell] = newX;

      print('листаем вправо: новая клетка по Ox: $newCell (значение: $newX)');
      _rebuildControllerCol.add(newCell);
    } else {
      //листаем влево
      newCell = (newCell - 1) % width;
      var newX = offsetCells.x.round();
      newX += widget.startCoordOx;
      newX = cellMapper.normalizeOx(newX);

      cellMapper.mapOx[newCell] = newX;
      print('листаем влево: новая клетка по Ox: $newCell (значение: $newX)');
      _rebuildControllerCol.add(newCell);
    }
    oldColOffset = newColOffset;
  }

  Offset mapCoordToOffset(int x, int y) => Offset(widget.cellSize.width * x, widget.cellSize.height * y);

  int constCellsOffsetY = 0;

  /// Вызывается при изменении положения камеры
  /// Вычисляет столбцы нуждающиеся в перестроении
  /// Для перестроения столбца вызывайте [_rebuildControllerRow.add]
  /// с номером строки (от 0 до height)
  void _rebuildY() {
    final newRowOffset = -(widget.offsetController.value.dy / widget.cellSize.height).ceil();
    if (newRowOffset == oldRowOffset) {
      return;
    }
    print('!!!!!!! ROW: $oldRowOffset => $newRowOffset');
    var newCell = newRowOffset.abs();
    if (newRowOffset < 0) {
      newCell = height - newCell;
    }

    final complexPoint = getCellsOffset(widget.offsetController.value, widget.cellSize);
    final offsetCells = complexPoint;
    final mult = ((offsetCells.y) / height).ceil();
    if ((oldRowOffset - newRowOffset) < 0) {
      //листаем вниз
      newCell = (height - 2 + newCell) % height;
      var newY = mult * height + newCell;
      newY += widget.startCoordOy;
      newY = cellMapper.normalizeOy(newY);

      cellMapper.mapOy[newCell] = newY;
      print('листаем вниз: новая клетка по Oy: $newCell (значение: $newY)');
      _rebuildControllerRow.add(newCell);
    } else {
      //листаем вверх
      newCell = (newCell - 1) % height;
      var newY = offsetCells.y.round();
      newY += widget.startCoordOy;
      newY = cellMapper.normalizeOy(newY);

      cellMapper.mapOy[newCell] = newY;
      print('листаем вверх: новая клетка по Oy: $newCell (значение: $newY)');
      _rebuildControllerRow.add(newCell);
    }

    oldRowOffset = newRowOffset;
  }

  //region Lifecycle
  @override
  void initState() {
    super.initState();
    resetToCoord(widget.startCoordOx, widget.startCoordOy);

    widget.offsetController
      ..addListener(_rebuildX)
      ..addListener(_rebuildY);
  }

  void resetToCoord(int x, int y) {
    print('resetToCoord: $x $y');
    startOffset = mapCoordToOffset(x, y);
    setState(() {
      _evalSizeTileCount(startX: x, startY: y);
    });
  }

  @override
  void didUpdateWidget(_BoardLayout oldWidget) {
    print('didUpdateWidget');
    /*
    widget.offsetController.reset();
    reset();
    setState(_evalSizeTileCount);

     */
    super.didUpdateWidget(oldWidget);
  }

  // Расчитываю сколько клеточек может
  // поместиться на экране по каждой оси
  // с небольшим запасом
  void _evalSizeTileCount({int startX = 0, int startY = 0}) {
    print('_evalSizeTileCount cell size:' + widget.boardSize.toString());
    width = ((widget.boardSize.width / widget.cellSize.width).ceil() + 2) * 2;
    height = ((widget.boardSize.height / widget.cellSize.height).ceil() + 2) * 2;
    cellMapper = CellMapper(
        width: width,
        height: height,
        startX: startX,
        startY: startY,
        isCycled: widget.isCycled,
        fullBoardSize: widget.fullBoardSize);
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

  void reset() {
    oldRowOffset = 0;
    oldColOffset = 0;
  }
  //endregion

  @override
  Widget build(BuildContext context) => Flow(
        delegate: _BoardFlowDelegate(width, height, widget.cellSize, widget.offsetController, startOffset: startOffset),
        children: _buildTiles(
          width,
          height,
          widget.cellSize,
        ).toList(growable: false),
      );

  bool leftTopScrolling = false;

  /// TODO: необходимо перестраивать клетки
  /// возвращая не исходные координаты виджетов
  /// , а результирующие координаты клетки [colOffset], [rowOffset]
  Iterable<Widget> _buildTiles(
    int width,
    int height,
    Size cellSize,
  ) sync* {
    final board = context.findAncestorWidgetOfExactType<_Board>()!;
    final builder = board.builder;
    //final cellSize = board.size;
    print('_buildTiles cellSize: ' + cellSize.toString());
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        yield SizedBox.fromSize(
          size: cellSize,
          child: StreamBuilder<int>(
            stream: _rebuildControllerCol.stream.where((v) => v == x),
            builder: (context, dataX) => StreamBuilder<int>(
              stream: _rebuildControllerRow.stream.where((v) => v == y),
              builder: (context, dataY) {
                final oy = cellMapper.mapOy[y] ?? -1;
                final ox = cellMapper.mapOx[x] ?? -1;

                if (widget.fullBoardSize.height.round() != 0) {
                  //!print('build Oy empty box');
                  if (oy < 0 || oy >= widget.fullBoardSize.height) {
                    return SizedBox(
                      width: cellSize.width,
                      height: cellSize.height,
                    );
                  }
                }
                if (widget.fullBoardSize.width.round() != 0) {
                  //!print('build Ox empty box');
                  if (ox < 0 || ox >= widget.fullBoardSize.width) {
                    return SizedBox(
                      width: cellSize.width,
                      height: cellSize.height,
                    );
                  }
                }

                return builder(ox, oy);
              },
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

  Offset startOffset;

  _BoardFlowDelegate(this.width, this.height, this.size, this.listenable, {this.startOffset = const Offset(0, 0)})
      : super(repaint: listenable);

  @override
  void paintChildren(FlowPaintingContext context) {
    //final boardSize = context.size;
    // Количество целых столбцов и строк на которые съехала доска
    // по горизонтали и вертикали
    final colOffset = -((listenable.value.dx) / size.width).ceil();
    final rowOffset = -((listenable.value.dy) / size.height).ceil();

    // Отступы для смещения в количестве досок
    var xBoardOffset = 0;
    var yBoardOffset = 0;

    var i = 0;
    for (var x = 0; x < width; x++) {
      // Перемещение столбца
      if (colOffset.isNegative) {
        xBoardOffset = math.min(((width + colOffset - x) / width).ceil() - 1, 0);
      } else {
        xBoardOffset = math.max(((colOffset - x) / width).ceil(), 0);
      }
      for (var y = 0; y < height; y++) {
        // Перемещение строки
        if (rowOffset.isNegative) {
          yBoardOffset = math.min(((height + rowOffset - y) / height).ceil() - 1, 0);
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
  final scrollThreshold = 20;
  Offset _lastNotifiedValue;
  bool _wasUpdated = false;

  _ThrottledOffsetController({
    required Offset initialValue,
    required num fps,
  })  : _lastNotifiedValue = initialValue,
        super(
          initialValue: initialValue,
          fps: fps,
        );

  void translate(double x, double y) => update(value.translate(x, y));

  @override
  bool update(Offset value) {
    _wasUpdated = super.update(value);
    return _wasUpdated;
  }

  void reset({double dx = 0, double dy = 0}) {
    _lastNotifiedValue = Offset(dx, dy);
    _value = Offset(dx, dy);
    notifyListeners();
  }
}

/// Value Notifier с троттлингом под заданое количество FPS
abstract class _ThrottledController<T extends Object> with ChangeNotifier implements ValueListenable<T> {
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
  bool update(T value) {
    _value = value;
    if (_stopwatch.elapsedMilliseconds < _delay) return false;
    notifyListeners();
    return true;
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

class CellMapper {
  final mapOx = <int, int>{};
  final mapOy = <int, int>{};

  final int startX;
  final int startY;

  /// Размер всей "доски" в тайлах по горизонтали и вертикали. По умолчанию - бесконечно
  final Size fullBoardSize;

  /// Зациклен ли скролл, по-умолчанию - нет
  final bool isCycled;

  CellMapper({
    required int width,
    required int height,
    this.startX = 0,
    this.startY = 0,
    this.fullBoardSize = const Size(0, 0),
    this.isCycled = false,
  }) {
    for (var i = 0; i < width; i++) {
      var newX = i + startX;
      //вырожденный случай
      if (i >= (width - 1)) {
        newX = startX - 1;
      }

      mapOx[i] = normalizeOx(newX);
    }
    for (var i = 0; i < height; i++) {
      var newY = i + startY;
      //вырожденный случай
      if (i >= (height - 1)) {
        newY = startY - 1;
      }

      mapOy[i] = normalizeOy(newY);
    }
  }

  int normalizeOy(int y) {
    var newY = y;
    if (isCycled && fullBoardSize.height.round() != 0) {
      while (newY >= fullBoardSize.height) {
        newY -= fullBoardSize.height.round();
      }
      while (newY < 0) {
        newY += fullBoardSize.height.round();
      }
    }
    return newY;
  }

  int normalizeOx(int x) {
    var newX = x;
    if (isCycled && fullBoardSize.width.round() != 0) {
      while (newX >= fullBoardSize.width) {
        newX -= fullBoardSize.width.round();
      }
      while (newX < 0) {
        newX += fullBoardSize.width.round();
      }
    }
    return newX;
  }
}
