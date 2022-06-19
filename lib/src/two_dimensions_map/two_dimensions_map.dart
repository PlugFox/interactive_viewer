import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_board/src/two_dimensions_map/map_flow_delegate.dart';
import 'package:game_board/src/two_dimensions_map/map_layout.dart';
import 'package:game_board/src/two_dimensions_map/map_properties.dart';
import 'package:game_board/src/two_dimensions_map/on_tap_processor.dart';
import 'package:game_board/src/two_dimensions_map/throttled_offset_controller.dart';

class TwoDimensionsMap extends StatefulWidget {
  const TwoDimensionsMap({
    required this.mapProperties,
    required this.coordinateBuilder,
    Key? key,
    this.isDebug = false,
  }) : super(key: key);

  final CoordinateBuilder coordinateBuilder;
  final MapProperties mapProperties;
  final bool isDebug;

  @override
  State<TwoDimensionsMap> createState() => _TwoDimensionsMapState();
}

class _TwoDimensionsMapState extends State<TwoDimensionsMap> {
  late final fullMapOx = widget.mapProperties.tileWidth * widget.mapProperties.tilesOxDisplayed;
  late final fullMapOy = widget.mapProperties.tileHeight * widget.mapProperties.tilesOyDisplayed;
  late final _controller = ThrottledOffsetController(
    initialValue: const Offset(0, 0),
    mapProperties: widget.mapProperties,
  );

  late final _onTapProcessor = OnTapProcessor(
    mapProperties: widget.mapProperties,
    controller: _controller,
  );

  double get scale => _controller.scale;
  Matrix4 matrix = Matrix4.identity();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Center(
            child: GestureDetector(
              onScaleUpdate: (scaleInfo) {
                _controller.translate(
                    scaleInfo.focalPointDelta.dx * scale / 2, scaleInfo.focalPointDelta.dy * scale / 2);

                print('scaleInfo.scale: ${scaleInfo.scale} / scale=$scale');
                if (scaleInfo.scale != 1) {
                  var _scale = scaleInfo.scale;
                  if (_scale < 0.5) {
                    _scale = 0.5;
                  }
                  if (_scale > 3) {
                    _scale = 3;
                  }

                  _scale = 1 / (_scale * 2);

                  _controller.scale = _scale;
                  _controller.zoomController.add(_scale);
                }
              },
              onTapDown: (details) {
                final pointTaped = _onTapProcessor.getPointTapped(details.localPosition);
              },
              child: StreamBuilder(
                stream: _controller.zoomController.stream,
                builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                  matrix[15] = snapshot.data ?? (1 / scale);

                  return Transform(
                    transform: matrix,
                    child: MapLayout(
                      offsetController: _controller,
                      mapProperties: widget.mapProperties,
                      coordinateBuilder: widget.coordinateBuilder,
                    ),
                  );
                },
              ),
            ),
          ),
          if (widget.isDebug)
            Positioned(
              width: min(200, MediaQuery.of(context).size.width),
              bottom: 5,
              height: 40,
              child: ColoredBox(
                color: const Color(0xFF000000),
                child: Center(
                  child: ValueListenableBuilder<Offset>(
                    builder: (context, value, child) => Text(
                      '${value.dx.truncate()} x ${value.dy.truncate()}',
                      style: const TextStyle(
                        height: 1,
                        fontSize: 12,
                        color: Color(0xFFFFFFFF),
                      ),
                      textAlign: TextAlign.center,
                      //maxLines: 2,
                      overflow: TextOverflow.clip,
                    ),
                    valueListenable: _controller.fullMapController,
                  ),
                ),
              ),
            ),
        ],
      );
}
