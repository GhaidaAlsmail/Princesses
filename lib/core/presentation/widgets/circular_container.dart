import 'dart:math';
import 'package:flutter/material.dart';

class WavyCircle extends StatelessWidget {
  final Color color;
  final double width;
  final double height;
  final Widget? child1; // النص + الأيقونة
  final Widget? child2; // الصورة
  final double? childSize1;
  final double? childSize2;
  final AlignmentGeometry childAlignment1;
  final AlignmentGeometry childAlignment2;

  const WavyCircle({
    super.key,
    required this.color,
    required this.width,
    required this.height,
    this.child1,
    this.child2,
    this.childSize1,
    this.childSize2,
    this.childAlignment1 = Alignment.topCenter,
    this.childAlignment2 = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    double size = min(width, height); // استخدام الحجم الممرر

    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: WavyCirclePainter(color: color),
          ),
          if (child1 != null)
            Align(
              alignment: childAlignment1,
              child: SizedBox(
                width: childSize1 ?? size * 0.5,
                height: childSize1 ?? size * 0.5,
                child: child1!,
              ),
            ),
          if (child2 != null)
            Align(
              alignment: childAlignment2,
              child: SizedBox(
                width: childSize2 ?? size * 0.3,
                height: childSize2 ?? size * 0.3,
                child: child2!,
              ),
            ),
        ],
      ),
    );
  }
}

class WavyCirclePainter extends CustomPainter {
  final Color color;

  WavyCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    const int waves = 60;
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double angleStep = 2 * pi / waves;
    final double waveDepth = 10;

    for (int i = 0; i <= waves; i++) {
      double angle = i * angleStep;
      double r = radius + sin(i * 0.5) * waveDepth;
      double x = center.dx + r * cos(angle);
      double y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
