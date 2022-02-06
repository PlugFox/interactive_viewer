import 'package:flutter/material.dart';

@immutable
class ViewerBoard extends StatefulWidget {
  const ViewerBoard({required this.fullBoardSize, required this.tileSize, required this.builder, Key? key})
      : super(key: key);

  final Size fullBoardSize;
  final double tileSize;
  final Widget Function(int x, int y) builder;

  @override
  State<ViewerBoard> createState() => _ViewerBoardState();
}

class _ViewerBoardState extends State<ViewerBoard> {
  final posList = <Widget>[];
  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.fullBoardSize.width.toInt(); i++) {
      for (var j = 0; j < widget.fullBoardSize.height.toInt(); j++) {
        posList.add(
          Positioned(
            left: i * widget.tileSize,
            top: j * widget.tileSize,
            child: SizedBox(
              width: widget.tileSize,
              height: widget.tileSize,
              child: widget.builder(i, j),
            ),
          ),
        );
      }
    }
    // ...
  }

  @override
  void dispose() {
    // ...
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => InteractiveViewer(
        minScale: 0.2,
        maxScale: 2,
        constrained: false,
        child: SizedBox(
          width: widget.tileSize * widget.fullBoardSize.width,
          height: widget.tileSize * widget.fullBoardSize.height,
          child: Stack(
            children: posList,
          ),
        ),
      );
}
