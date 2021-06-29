import 'package:flutter/widgets.dart';

class Board extends StatelessWidget {
  const Board({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: List<Widget>.generate(
          8,
          (i) => Expanded(
            flex: 1,
            child: Row(
              children: List<Widget>.generate(
                8,
                (j) => Expanded(
                  flex: 1,
                  child: BoardCell(
                    x: j,
                    y: i,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

@immutable
class BoardCell extends StatelessWidget {
  static const Color _black = Color(0xFF000000);
  static const Color _white = Color(0xFFFFFFFF);
  static final int _aCode = 'A'.codeUnitAt(0);

  final int x;
  final int y;

  const BoardCell({
    required this.x,
    required this.y,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final whiteCell = x.isOdd ^ y.isOdd;
    return ColoredBox(
      color: whiteCell ? _white : _black,
      child: Center(
        child: Text(
          '${String.fromCharCode(x + _aCode)}${y + 1}',
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            color: whiteCell ? _black : _white,
            fontSize: 48,
          ),
        ),
      ),
    );
  }
}
