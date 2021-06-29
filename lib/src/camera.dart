import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Camera extends StatefulWidget {
  final bool debug;
  final Widget child;
  final Size size;

  const Camera({
    required this.child,
    this.debug = false,
    this.size = const Size.square(1000),
    Key? key,
  }) : super(key: key);

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  final TransformationController _controller =
      TransformationController(Matrix4.identity());

  @override
  void initState() {
    super.initState();
    //..translate(-200.0, -200.0);
    _centerBoard();
  }

  void _centerBoard() {
    final screenSize = ui.window.physicalSize / ui.window.devicePixelRatio;
    final boardSize = widget.size;
    // ignore: unnecessary_parenthesis
    final offset = (screenSize / 2 - boardSize / 2) as Offset;
    _controller.value = Matrix4.identity()..translate(offset.dx, offset.dy);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: <Positioned>[
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _controller,
              scaleEnabled: false,
              panEnabled: true,
              constrained: false,
              boundaryMargin: EdgeInsets.zero,
              child: SizedBox.fromSize(
                size: widget.size,
                child: widget.child,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            height: 42,
            width: 42,
            child: FloatingActionButton(
              onPressed: _centerBoard,
              child: const Icon(
                Icons.stream,
                size: 42,
              ),
            ),
          ),
          if (widget.debug)
            Positioned(
              bottom: 10,
              left: 10,
              height: 25,
              width: 150,
              child: _CameraDebugLabel(
                valueListenable: _controller,
              ),
            ),
        ],
      );
}

@immutable
class _CameraDebugLabel extends StatelessWidget {
  final ValueListenable<Matrix4> valueListenable;

  const _CameraDebugLabel({
    required this.valueListenable,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: const Color(0xFF000000),
        child: Center(
          child: ValueListenableBuilder<Matrix4>(
              valueListenable: valueListenable,
              builder: (context, value, _) {
                final translation = value.getTranslation().xy;
                final x = (translation.x * 1000).truncateToDouble() / 1000;
                final y = (translation.y * 1000).truncateToDouble() / 1000;
                return Text(
                  '$x x $y',
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 12,
                  ),
                );
              }),
        ),
      );
}
