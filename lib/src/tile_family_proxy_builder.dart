import 'package:flutter/material.dart';

@immutable
class TileFamilyProxyBuilder extends StatefulWidget {
  const TileFamilyProxyBuilder(
      {required this.parentOffset,
      required this.fullBoardSize,
      required this.tileSize,
      required this.builder,
      this.tilesInProxy = const Size(3, 3),
      Key? key})
      : super(key: key);

  /// Размер всей "доски" в тайлах по горизонтали и вертикали. По умолчанию - бесконечно ( Size(0,0) )
  /// Size(0,10) - соответствует бесконечной оси Ox и 10 клеток по Oy
  final Size fullBoardSize;

  /// Размер одного тайла
  final Size tileSize;

  final Widget Function(int x, int y) builder;

  final Offset parentOffset;
  final Size tilesInProxy;

  @override
  State<TileFamilyProxyBuilder> createState() => _TileFamilyProxyBuilderState();
}

class _TileFamilyProxyBuilderState extends State<TileFamilyProxyBuilder> {
  final List<Widget> positionedList = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.tilesInProxy.width; i++) {
      for (var j = 0; j < widget.tilesInProxy.height; j++) {
        var x = (i + widget.parentOffset.dx * widget.tilesInProxy.width).toInt();
        if (x >= widget.fullBoardSize.width) {
          x -= widget.fullBoardSize.width.toInt();
        }
        if (x < 0) {
          x += widget.fullBoardSize.width.toInt();
        }
        var y = (j + widget.parentOffset.dy * widget.tilesInProxy.height).toInt();
        if (y >= widget.fullBoardSize.height) {
          y -= widget.fullBoardSize.height.toInt();
        }
        if (y < 0) {
          y += widget.fullBoardSize.height.toInt();
        }
        final posWidget = Positioned(
            left: i * widget.tileSize.width,
            top: j * widget.tileSize.height,
            child: SizedBox(
              width: widget.tileSize.width,
              height: widget.tileSize.height,
              child: widget.builder(x, y),
            ));
        positionedList.add(posWidget);
      }
    }
    positionedList.add(
      Positioned(
        bottom: 5,
        child: Container(
          color: Colors.white,
          child: Text('dx: ${widget.parentOffset.dx}, dy: ${widget.parentOffset.dy},'),
        ),
      ),
    );
    // ...
  }

  @override
  void dispose() {
    // ...
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.purple,
        child: Stack(
          children: positionedList,
        ),
      );
}
