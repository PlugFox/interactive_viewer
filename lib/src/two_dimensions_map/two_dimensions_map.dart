import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_board/src/two_dimensions_map/debouncer.dart';
import 'package:game_board/src/two_dimensions_map/map_controller.dart';
import 'package:game_board/src/two_dimensions_map/map_controller_event.dart';
import 'package:game_board/src/two_dimensions_map/map_flow_delegate.dart';
import 'package:game_board/src/two_dimensions_map/map_layout.dart';
import 'package:game_board/src/two_dimensions_map/on_tap_processor.dart';
import 'package:game_board/src/two_dimensions_map/scale_animator.dart';

class TwoDimensionsMap extends StatefulWidget {
  const TwoDimensionsMap({
    required this.mapControllerImpl,
    required this.coordinateBuilder,
    Key? key,
    this.isDebug = false,
    this.clickCallback,
  }) : super(key: key);

  final CoordinateBuilder coordinateBuilder;
  final MapControllerImpl mapControllerImpl;
  final bool isDebug;

  final ClickCallback? clickCallback;

  @override
  State<TwoDimensionsMap> createState() => _TwoDimensionsMapState();
}

class _TwoDimensionsMapState extends State<TwoDimensionsMap> with SingleTickerProviderStateMixin {
  late final fullMapOx =
      widget.mapControllerImpl.mapProperties.tileWidth * widget.mapControllerImpl.mapProperties.tilesOxDisplayed;
  late final fullMapOy =
      widget.mapControllerImpl.mapProperties.tileHeight * widget.mapControllerImpl.mapProperties.tilesOyDisplayed;

  late final _onTapProcessor = OnTapProcessor(
    mapProperties: widget.mapControllerImpl.mapProperties,
    controller: widget.mapControllerImpl,
  );

  double get scale => widget.mapControllerImpl.zoom;
  Matrix4 matrix = Matrix4.identity();

  @override
  void initState() {
    super.initState();
    widget.mapControllerImpl.initOffsetAnimations(tickerProvider: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.mapControllerImpl.setScreenSize(MediaQuery.of(context).size);
  }

  @override
  void dispose() {
    super.dispose();
  }

  final debouncer = Debouncer(delayMs: 100);
  double _localZoom = 2;
  void zoom(double scale) {
    debouncer.run(() {
      widget.mapControllerImpl.addEvent(MapControllerEvent.zoom(scale: _localZoom));
    });
  }

  bool _scaleLocked = false;
  TapDownDetails? lastDetails;

  double roundedZoom = 1;

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: <Widget>[
          GestureDetector(
            onScaleUpdate: (scaleInfo) {
              _scaleLocked = true;

              widget.mapControllerImpl
                  .translate(scaleInfo.focalPointDelta.dx / roundedZoom, scaleInfo.focalPointDelta.dy / roundedZoom);

              if (scaleInfo.scale != 1) {
                if (scaleInfo.scale > 1) {
                  _localZoom += 0.01;
                  if (_localZoom > widget.mapControllerImpl.mapProperties.maxZoomIn) {
                    _localZoom = widget.mapControllerImpl.mapProperties.maxZoomIn;
                  }
                  zoom(widget.mapControllerImpl.zoom + 0.25);
                } else {
                  _localZoom -= 0.01;
                  if (_localZoom < 1) {
                    _localZoom = 1;
                  }
                  zoom(widget.mapControllerImpl.zoom - 0.2);
                }
              }
              _scaleLocked = false;
            },
            onTap: () {
              if (_scaleLocked || widget.clickCallback == null || lastDetails == null) {
                return;
              }
              final pointTaped = _onTapProcessor.getPointTapped(lastDetails!.localPosition);
              widget.clickCallback!(pointTaped.x, pointTaped.y);
            },
            onTapDown: (details) {
              lastDetails = details;
            },
            child: ClipRect(
              clipper: RectCustomClipper(),
              child: ScaleAnimator(
                maxZoomIn: widget.mapControllerImpl.mapProperties.maxZoomIn,
                animateToStream: widget.mapControllerImpl.mapStateStream
                    .where((e) => e.whatChanged == MapEventType.setZoom)
                    .map((s) => s.zoom),
                scaleCallbackFunc: (scale) {
                  widget.mapControllerImpl.zoom = scale;
                  if (scale >= 2 && scale <= 3) {
                    roundedZoom = 2;
                  }
                  if (scale > 3) {
                    roundedZoom = 4;
                  }
                },
                child: MapLayout(
                  offsetController: widget.mapControllerImpl,
                  mapProperties: widget.mapControllerImpl.mapProperties,
                  coordinateBuilder: widget.coordinateBuilder,
                ),
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
                    valueListenable: widget.mapControllerImpl.fullMapController,
                  ),
                ),
              ),
            ),
        ],
      );
}

class RectCustomClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width, size.height);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => oldClipper != this;
}
