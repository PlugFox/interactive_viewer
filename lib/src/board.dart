import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef CellBuilder = Widget Function(int x, int y);

@immutable
class Board extends StatelessWidget {
  final Size widgetSize;
  final CellBuilder builder;

  const Board({
    required this.builder,
    required this.widgetSize,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _Board(
        builder: builder,
        size: widgetSize,
      );
}

@immutable
class _Board extends StatefulWidget {
  final Size size;
  final CellBuilder builder;

  const _Board({
    required this.builder,
    required this.size,
    Key? key,
  }) : super(key: key);

  @override
  State<_Board> createState() => _BoardState();
}

// ignore: prefer_mixin
class _BoardState extends State<_Board> {
  final ValueNotifier<Offset> _listenable = ValueNotifier<Offset>(const Offset(0, 0));

  //region Lifecycle
  @override
  void initState() {
    super.initState();
    // Первичная инициализация виджета
  }

  @override
  void didUpdateWidget(_Board oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Конфигурация виджета изменилась
  }

  @override
  void dispose() {
    // Перманетное удаление стейта из дерева
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
  Widget build(BuildContext context) => SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          GestureDetector(
            onPanStart: (DragStartDetails details) {},
            onPanCancel: () {},
            onPanDown: (details) {},
            onPanEnd: (details) {},
            onPanUpdate: (details) {
              _listenable.value = _listenable.value.translate(details.delta.dx, details.delta.dy);
            },
            child: ColoredBox(
              color: const Color(0xFF7F7F7F),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Расчитываю сколько клеточек может
                  // поместиться на экране по каждой оси
                  // с небольшим запасом
                  final boardSize = constraints.biggest;
                  final cellSize = widget.size;
                  final width = (boardSize.width / cellSize.width).ceil() + 1;
                  final height = (boardSize.height / cellSize.height).ceil() + 1;
                  return Flow(
                    delegate: _BoardFlowDelegate(width, height, cellSize, _listenable, boardSize),
                    children: _buildCells(width, height).toList(growable: false),
                  );
                },
              ),
            ),
          ),
          Positioned(
              left: 0,
              top: MediaQuery.of(context).size.height - 100,
              child: Container(
                decoration: BoxDecoration(color: Colors.white, border: Border.all(width: 2)),
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: ValueListenableBuilder<Offset>(
                    builder: (context, value, child) => Text('Camera pos: (${value.dx.round()};${value.dy.round()})'),
                    valueListenable: _listenable,
                  ),
                ),
              ))
        ],
      ));
}

class _BoardFlowDelegate extends FlowDelegate {
  final ValueListenable<Offset> listenable;
  final int width;
  final int height;
  final Size boardSize;
  final Size size;

  _BoardFlowDelegate(
    this.width,
    this.height,
    this.size,
    this.listenable,
    this.boardSize,
  ) : super(repaint: listenable);

  @override
  void paintChildren(FlowPaintingContext context) {
    // Количество целых столбцов и строк на которые съехала доска
    // по горизонтали и вертикали
    final colOffset = -(listenable.value.dx / size.width).ceil();
    final rowOffset = -(listenable.value.dy / size.height).ceil();

    // Отступы для смещения в количестве досок
    var xBoardOffset = 0;
    var yBoardOffset = 0;

    var i = 0;
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        // Перемещение столбца
        if (colOffset.isNegative) {
          xBoardOffset = ((width + colOffset - x) / width).ceil() - 1;
          if (xBoardOffset > 0) {
            xBoardOffset = 0;
          } else {
            //print('x: $x xBoardOffset: $xBoardOffset');
          }
        } else {
          xBoardOffset = ((colOffset - x) / width).ceil();
          if (xBoardOffset.isNegative) {
            xBoardOffset = 0;
          }
        }

        // Перемещение строки

        if (rowOffset.isNegative) {
          yBoardOffset = ((height + rowOffset - y) / height).ceil() - 1;
          if (yBoardOffset > 0) {
            yBoardOffset = 0;
          } else {}
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
            x * size.width + listenable.value.dx + xBoardOffset * width * size.width,
            y * size.height + listenable.value.dy + yBoardOffset * height * size.height,
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
