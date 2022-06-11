import 'package:flutter/material.dart';
import 'package:game_board/src/two_dimensions_map/map_properties.dart';
import 'package:game_board/src/two_dimensions_map/two_dimensions_map.dart';

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

  static const mapProperties = MapProperties(
    tileWidth: 100,
    tileHeight: 100,
    tilesOx: 10,
    tilesOy: 10,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: TwoDimensionsMap(
            isDebug: true,
            mapProperties: mapProperties,
            coordinateBuilder: (int x, int y) => Container(
              color: (x + y) % 2 == 0 ? Colors.black : Colors.white12,
              width: mapProperties.tileWidth,
              height: mapProperties.tileHeight,
              child: Center(
                child: Text(
                  '[$x;$y]',
                  style: TextStyle(color: (x + y) % 2 == 0 ? Colors.white : Colors.black),
                ),
              ),
            ),
          ),
        ),
      );

/*
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
            fullBoardSize: const Size(0, 10), // (full bord size)
            builder: (x, y) {
              //print('Rebuild: $x x $y');
              return BoardTile(x: x, y: y);
            },
          ),
        ),
      );

   */
}
