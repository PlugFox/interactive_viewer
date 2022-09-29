import 'package:flutter/material.dart';

import 'map_controller.dart';
import 'map_flow_delegate.dart';
import 'map_properties.dart';
import 'tiles_builder.dart';

class MapLayout extends StatefulWidget {
  const MapLayout({
    required this.offsetController,
    required this.mapProperties,
    required this.coordinateBuilder,
    Key? key,
  }) : super(key: key);

  final MapProperties mapProperties;
  final CoordinateBuilder coordinateBuilder;

  /// Контроллер положения камеры
  final MapControllerImpl offsetController;

  @override
  State<MapLayout> createState() => _MapLayoutState();
}

class _MapLayoutState extends State<MapLayout> {
  late final tilesBuilder = TilesBuilder(
    mapProperties: widget.mapProperties,
    coordinateBuilder: widget.coordinateBuilder,
    offsetController: widget.offsetController,
  );

  @override
  void initState() {
    super.initState();

    //widget.offsetController.fullMapController.addListener(tilesBuilder.rebuildPosition);
  }

  @override
  void dispose() {
    tilesBuilder.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Flow(
        clipBehavior: Clip.hardEdge,
        delegate: MapFlowDelegate(
          listenable: widget.offsetController.renderController,
          tilesBuilder: tilesBuilder,
        ),
        children: tilesBuilder.buildTiles(widget.offsetController.renderController.value).toList(growable: false),
      );
}
