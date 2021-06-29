import 'package:flutter/material.dart';
import 'package:game_board/src/board.dart';
import 'package:game_board/src/camera.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'GameBoard',
        home: Scaffold(
          body: SafeArea(
            child: Camera(
              debug: true,
              child: Board(),
            ),
          ),
        ),
      );
}
