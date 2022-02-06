import 'package:flutter/material.dart';
import 'package:game_board/src/tile.dart';
import 'package:game_board/src/viewer_board.dart';

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
  Widget build(BuildContext context) {
    const proxyLength = 5;
    const tileSize = 160.0;
    final tileSizeModif = (tileSize * proxyLength).roundToDouble();

    print('tileSize: $tileSize , tileSizeModif: $tileSizeModif');

    const boardSizeOx = 20.0;
    const boardSizeOy = 20.0;

    final posList = <Widget>[];
    for (var i = 0; i < 20; i++) {
      for (var j = 0; j < 20; j++) {
        posList.add(
          Positioned(
            left: i * tileSize,
            top: j * tileSize,
            child: InkWell(
                onTap: () {
                  print('tapped: $i;$j');
                },
                child: SizedBox(width: tileSize, height: tileSize, child: BoardTile(x: i, y: j))),
          ),
        );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: ViewerBoard(
          tileSize: 160,
          fullBoardSize: Size(20, 20),
          builder: (x, y) => InkWell(
              onTap: () {
                print('tapped: $x;$y');
              },
              child: BoardTile(x: x, y: y)),
        ),
      ),
    );
  }
}

/*
return Scaffold(
      body: SafeArea(
        child: Board(
          zoomOutScale: 1,
          tileSize: Size(tileSizeModif, tileSizeModif),
          fps: 60,
          debug: true,
          startCoordOx: 3,
          startCoordOy: 3,
          isCycled: true, // Is behaving like globus (coords: 0,1,2,3,0,1,2,3)
          fullBoardSize: Size((boardSizeOx / proxyLength).roundToDouble(),
              (boardSizeOy / proxyLength).roundToDouble()), // (full bord size)

          builder: (dx, dy) => TileFamilyProxyBuilder(
            tilesInProxy: Size(proxyLength.toDouble(), proxyLength.toDouble()),
            parentOffset: Offset(dx.toDouble(), dy.toDouble()),
            fullBoardSize: Size(boardSizeOx, boardSizeOy),
            tileSize: Size(tileSize, tileSize),
            builder: (x, y) => BoardTile(x: x, y: y),
          ),
        ),
      ),
    );
 */
/*
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
 */
