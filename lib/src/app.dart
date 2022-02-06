import 'package:flutter/material.dart';
import 'package:game_board/src/board.dart';
import 'package:game_board/src/tile.dart';
import 'package:game_board/src/tile_family_proxy_builder.dart';

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
    const tileSize = 121.0;
    final tileSizeModif = (tileSize * proxyLength).roundToDouble();

    print('tileSize: $tileSize , tileSizeModif: $tileSizeModif');

    const boardSizeOx = 20.0;
    const boardSizeOy = 20.0;

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
            builder: (x, y) {
              //print('Rebuild: $x x $y');
              return BoardTile(x: x, y: y);
            },
          ),
        ),
      ),
    );
  }
}

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
