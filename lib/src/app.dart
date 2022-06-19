import 'package:flutter/material.dart';
import 'package:game_board/src/two_dimensions_map/map_properties.dart';
import 'package:game_board/src/two_dimensions_map/two_dimensions_map.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Board',
        home: Home(),
      );
}

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final mapProperties = MapProperties(
    tileWidth: 64,
    tileHeight: 64,
    tilesOx: 40,
    tilesOy: 40,
    tilesOxDisplayed: 12,
    tilesOyDisplayed: 16,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: TwoDimensionsMap(
            isDebug: true,
            mapProperties: mapProperties,
            coordinateBuilder: (int x, int y, String? debug) => Container(
              decoration: BoxDecoration(
                  color: (x + y) % 2 == 0 ? Colors.black : Colors.white12,
                  border: Border.all(
                    width: 3,
                    color: (x + y) % 2 == 1 ? Colors.black : Colors.white12,
                  )),
              width: mapProperties.tileWidth,
              height: mapProperties.tileHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '[$x;$y]',
                    style: TextStyle(color: (x + y) % 2 == 0 ? Colors.white : Colors.black),
                  ),
                  Text(
                    debug ?? '-',
                    style: TextStyle(color: (x + y) % 2 == 0 ? Colors.white : Colors.black),
                  )
                ],
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

class TestWidget extends StatelessWidget {
  const TestWidget({
    required this.name,
    required this.widget,
    Key? key,
  }) : super(key: key);
  final Widget widget;
  final String name;

  @override
  Widget build(BuildContext context) {
    print(name);
    return SizedBox(
      key: key,
      child: widget,
    );
  }
}
