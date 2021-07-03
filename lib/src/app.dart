import 'package:flutter/material.dart';
import 'package:game_board/src/board.dart';
import 'package:game_board/src/tile.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Board',
        home: Home(),
      );
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Board(
            tileSize: const Size(120, 120),
            fps: 60,
            debug: true,
            builder: (x, y) => BoardTile(x: x, y: y),
          ),
        ),
      );
}
