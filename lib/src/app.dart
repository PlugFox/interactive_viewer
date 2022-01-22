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
            zoomOutScale: 2,
            tileSize: const Size(121, 121),
            fps: 60,
            debug: true,
            startCoordOx: 3,
            startCoordOy: 3,
            isCycled: true, // Is behaving like globus (coords: 0,1,2,3,0,1,2,3)
            fullBoardSize: const Size(9, 9), // (full bord size)

            builder: (x, y) {
              //print('Rebuild: $x x $y');
              return BoardTile(x: x, y: y);
            },
          ),
        ),
      );
}
