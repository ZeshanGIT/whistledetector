library circle_wave_progress;

import 'dart:math';

import 'package:flutter/material.dart';

class CircleWaveProgress extends StatefulWidget {
  final double size;
  final Color backgroundColor;
  final Color waveColor;
  final Color borderColor;
  final borderWidth;
  final double progress;
  final Text childText;

  CircleWaveProgress({
    this.size = 200.0,
    this.backgroundColor = Colors.blue,
    this.waveColor = Colors.white,
    this.borderColor = Colors.white,
    this.borderWidth = 10.0,
    this.progress = 50.0,
    this.childText = const Text(''),
  }) : assert(progress >= 0 && progress <= 100,
            'Valid range of progress value is [0.0, 100.0]');

  @override
  _WaveWidgetState createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<CircleWaveProgress>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    /// Only run the animation if the progress > 0. Since we don't need to draw the wave when progress = 0
    if (widget.progress > 0) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = Size(
      MediaQuery.of(context).size.width * 0.8,
      MediaQuery.of(context).size.height * 0.8,
    );

    return Container(
      width: widget.size,
      height: widget.size,
      child: ClipPath(
        clipper: CircleClipper(),
        child: AnimatedBuilder(
            animation: _animationController,
            builder: (BuildContext context, Widget child) {
              return Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      color: Colors.amber,
                      width: size.width,
                      height: size.width,
                      child: CustomPaint(
                        painter: WaveWidgetPainter(
                          animation: _animationController,
                          backgroundColor: widget.backgroundColor,
                          waveColor: widget.waveColor,
                          borderColor: widget.borderColor,
                          borderWidth: widget.borderWidth,
                          progress: widget.progress,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      widget.childText.data,
                      textAlign: TextAlign.center,
                      style: widget.childText.style.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  buildClipPath(),
                ],
              );
            }),
      ),
    );
  }

  ClipPath buildClipPath() {
    Size size = Size(200, 200);
    double amp = 15.0;
    double p = (100 - widget.progress) / 100.0;
    double baseHeight = p * size.height;
    Path path = Path();
    path.moveTo(0.0, baseHeight);
    for (double i = 0.0; i < size.width; i++) {
      path.lineTo(
        i,
        baseHeight +
            sin((i / size.width * 2 * pi) +
                    (_animationController.value * 2 * pi)) *
                amp,
      );
    }

    path.lineTo(size.width, 0.0);
    path.lineTo(0.0, size.height * 2);
    path.close();
    return ClipPath(
      clipper: MyClipper(path),
      child: Align(
        alignment: Alignment.center,
        child: widget.childText,
      ),
    );
  }
}

class WaveWidgetPainter extends CustomPainter {
  Animation<double> animation;
  Color backgroundColor, waveColor, borderColor;
  double borderWidth;
  double progress;

  WaveWidgetPainter(
      {this.animation,
      this.backgroundColor,
      this.waveColor,
      this.borderColor,
      this.borderWidth,
      this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    /// Draw background
    Paint backgroundPaint = Paint()
      ..color = this.backgroundColor
      ..style = PaintingStyle.fill;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, backgroundPaint);

    /// Draw wave
    Paint wavePaint = new Paint()..color = waveColor;
    double amp = 15.0;
    double p = progress / 100.0;
    double baseHeight = (1 - p) * size.height;

    Path path = Path();
    path.moveTo(0.0, baseHeight);
    for (double i = 0.0; i < size.width; i++) {
      path.lineTo(
        i,
        baseHeight +
            sin(
                  (i / size.width * 2 * pi) + (animation.value * 2 * pi),
                ) *
                amp,
      );
    }

    path.lineTo(200, 200);
    path.lineTo(0.0, size.height);
    path.close();
    canvas.drawPath(path, wavePaint);

    /// Draw border
    Paint borderPaint = Paint()
      ..color = this.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = this.borderWidth;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(
        new Rect.fromCircle(
            center: new Offset(size.width / 2, size.height / 2),
            radius: size.width / 2),
      );
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class MyClipper extends CustomClipper<Path> {
  final Path path;
  MyClipper(this.path);

  @override
  Path getClip(Size size) {
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
