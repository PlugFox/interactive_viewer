import 'package:flutter/material.dart';
import 'package:game_board/src/board.dart';

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
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SafeArea(
            child: Board(
              tileSize: const Size(120, 120),
              fps: 60,
              builder: (x, y) => Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(border: Border.all()),
                child: Center(
                  child: Text('$x x $y'),
                ),
              ),
            ),
          ),
        ),
      );
}
