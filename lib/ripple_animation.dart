import 'dart:async';

import 'package:flutter/material.dart';

class RippleAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double minRadius;
  final Color? color;
  final int ripplesCount;
  final Duration duration;
  final bool repeat;

  const RippleAnimation({super.key,
    required this.child,
    this.color,
    this.delay = const Duration(milliseconds: 0),
    this.repeat = false,
    this.minRadius = 60,
    this.ripplesCount = 5,
    this.duration = const Duration(milliseconds: 2300),
  });

  @override
  _RippleAnimationState createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    Timer(widget.delay, () {
      widget.repeat ? _controller.repeat() : _controller.forward();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CirclePainter(
        _controller,
        color: widget.color ?? Colors.black,
        minRadius: widget.minRadius,
        wavesCount: widget.ripplesCount + 2,
      ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CirclePainter extends CustomPainter {
  CirclePainter(
      this._animation, {
        required this.minRadius,
        required this.wavesCount,
        required this.color,
      }) : super(repaint: _animation);
  final Color color;
  final double minRadius;
  int wavesCount;
  final Animation<double> _animation;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    for (var wave = 0; wave <= wavesCount; wave++) {
      circle(canvas, rect, minRadius, wave, _animation.value, wavesCount);
    }
  }

  void circle(Canvas canvas, Rect rect, double minRadius, int wave,
      double value, int length) {
    Color _color;
    double r;
    if (wave != 0) {
      var opacity = (1 - ((wave - 1) / length) - value).clamp(0.0, 1.0);
      _color = color.withOpacity(opacity);

      r = minRadius * (1 + ((wave * value))) * value;
      final paint = Paint()..color = _color;
      canvas.drawCircle(rect.center, r, paint);
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) => true;
}
