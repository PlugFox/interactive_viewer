import 'package:flutter/material.dart';
import 'package:game_board/src/board.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Board',
        home: Scaffold(
          body: SafeArea(
            child: Board(
              builder: (x, y) => DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: const Color(0xFF000000),
                  ),
                ),
                child: Center(
                  child: Text('$x x $y'),
                ),
              ),
            ),
          ),
        ),
      );
}
