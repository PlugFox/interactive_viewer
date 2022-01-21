import 'package:flutter/material.dart';
import 'package:game_board/src/board.dart';
import 'package:game_board/src/tile.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'Board',
        home: Home(),
      );
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Board(
            tileSize: const Size(120, 120),
            fps: 120,
            debug: true,
            startCoordOx: 3,
            startCoordOy: 3,
            isCycled: true, // Is behaving like globus (coords: 0,1,2,3,0,1,2,3)
            fullBoardSize: const Size(3, 3), // (full bord size)
            builder: (x, y) {
              //print('Rebuild: $x x $y');
              return BoardTile(x: x, y: y);
            },
          ),
        ),
      );
}
