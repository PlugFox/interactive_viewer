import 'package:flutter/widgets.dart';

@immutable
class BoardTile extends StatelessWidget {
  static const Color _black = Color(0xFF000000);
  static const Color _white = Color(0xFFFFFFFF);

  final int x;
  final int y;

  const BoardTile({
    required this.x,
    required this.y,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final whiteCell = x.isOdd ^ y.isOdd;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: whiteCell ? _white : _black,
        border: Border.all(
          color: whiteCell ? _black : _white,
        ),
      ),
      child: Center(
        child: Text(
          '${x + 1} : ${y + 1}',
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            color: whiteCell ? _black : _white,
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}
