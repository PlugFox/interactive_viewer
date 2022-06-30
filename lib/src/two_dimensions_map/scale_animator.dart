import 'dart:async';

import 'package:flutter/material.dart';

typedef ValueCallback<T> = Function(T value);

class ScaleAnimator extends StatefulWidget {
  const ScaleAnimator({
    required this.animateToStream,
    required this.scaleCallbackFunc,
    required this.child,
    this.maxZoomIn = 1,
    Key? key,
  }) : super(key: key);

  /// Values from 0.0 to 1.0
  final Stream<double> animateToStream;
  final ValueCallback<double> scaleCallbackFunc;

  final Widget child;
  final double maxZoomIn;

  @override
  State<ScaleAnimator> createState() => _ScaleAnimatorState();
}

class _ScaleAnimatorState extends State<ScaleAnimator> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  StreamSubscription? sub;

  @override
  void initState() {
    super.initState();
    sub = widget.animateToStream.listen((e) {
      final animateToValue = e / widget.maxZoomIn;
      _controller.animateTo(animateToValue);
    });
    _controller.animateTo(1 / widget.maxZoomIn);
    _animation.addListener(_handleAnimation);
  }

  @override
  void dispose() {
    sub?.cancel();
    _animation.removeListener(_handleAnimation);
    super.dispose();
  }

  double adjScale = 1;
  void _handleAnimation() {
    final scale = _animation.value * widget.maxZoomIn;
    adjScale = scale < 1.0 ? 1.0 : scale;
    widget.scaleCallbackFunc(adjScale);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext _, Widget? child) => Transform.scale(
          alignment: Alignment.center,
          scale: adjScale,
          child: child,
        ),
        child: widget.child,
      );
}
