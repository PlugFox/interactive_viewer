import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_board/src/two_dimensions_map/map_controller.dart';
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

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: SafeArea(
          child: MapWrapper(),
        ),
      );
}

class MapWrapper extends StatefulWidget {
  const MapWrapper({Key? key}) : super(key: key);

  @override
  State<MapWrapper> createState() => _MapWrapperState();
}

class _MapWrapperState extends State<MapWrapper> {
  final centerSc = StreamController<Point<int>>();
  final mapProperties = MapProperties(
    tileWidth: 64,
    tileHeight: 64,
    tilesOx: 40,
    tilesOy: 40,
    tilesOxDisplayed: 12,
    tilesOyDisplayed: 16,
  );
  late final MapControllerImpl _mapControllerImpl;

  @override
  void initState() {
    super.initState();
    _mapControllerImpl = MapControllerImpl(
      mapProperties: mapProperties,
      screenSize: const Size(100, 100),
    );
    centerSc.add(const Point(10, 10));
    Future<void>.delayed(const Duration(seconds: 2)).then((_) => centerSc.add(const Point(15, 15)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mapControllerImpl.setScreenSize(MediaQuery.of(context).size);
  }

  @override
  void dispose() {
    centerSc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TwoDimensionsMap(
        isDebug: true,
        mapControllerImpl: _mapControllerImpl,
        clickCallback: (x, y) {
          print('point clicked: $x,$y');
        },
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
      );
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
