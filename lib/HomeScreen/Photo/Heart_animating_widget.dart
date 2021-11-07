///To display heart animation

import 'package:flutter/material.dart';

class HeartAnimatingWidget extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final bool alwaysAnimate;
  final Duration duration;
  final VoidCallback? onEnd;
  const HeartAnimatingWidget({
    required this.child,
    this.alwaysAnimate = false,
    this.duration = const Duration(milliseconds: 150),
    required this.isAnimating,
    this.onEnd,
    Key? key,
  }) : super(key: key);

  @override
  _HeartAnimatingWidgetState createState() => _HeartAnimatingWidgetState();
}

class _HeartAnimatingWidgetState extends State<HeartAnimatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final halfDuration = widget.duration.inMilliseconds;
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: halfDuration),
    );
    scale = Tween<double>(begin: 1, end: 1.2).animate(controller);
  }

  @override
  void didUpdateWidget(covariant HeartAnimatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      doAnimation();
    }
  }

  Future doAnimation() async {
    if (widget.isAnimating || widget.alwaysAnimate) {
      await controller.forward();
      await controller.reverse();
      await Future.delayed(Duration(milliseconds: 400));
      if (widget.onEnd != null) {
        widget.onEnd!();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: scale,
        child: widget.child,
      );
}
