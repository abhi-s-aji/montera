import 'package:flutter/material.dart';

class MonetraChart extends StatelessWidget {
  final List<double> dataPoints;
  final Color lineColor;
  final bool isSmooth;

  const MonetraChart({
    super.key,
    required this.dataPoints,
    required this.lineColor,
    this.isSmooth = true,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const Center(child: Text('No chart data available'));
    }

    final surfaceColor = Theme.of(context).canvasColor;

    return SizedBox(
      height: 160,
      width: double.infinity,
      child: CustomPaint(
        painter: _ChartPainter(
          dataPoints: dataPoints,
          lineColor: lineColor,
          surfaceColor: surfaceColor,
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final Color surfaceColor;

  _ChartPainter({
    required this.dataPoints,
    required this.lineColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final points = <Offset>[];
    final stepX = size.width / (dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final normalizedY = (dataPoints[i] - minVal) / range;
      // Add extra margin top and bottom
      final y = size.height - (normalizedY * (size.height - 30) + 15);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + stepX / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + stepX / 2, p2.dy);
      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
          controlPoint2.dy, p2.dx, p2.dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineColor.withValues(alpha: 0.25),
        lineColor.withValues(alpha: 0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = fillGradient
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw end-point indicator for polish
    final lastPoint = points.last;
    final dotBgPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(lastPoint, 6.0, dotBgPaint);
    canvas.drawCircle(lastPoint, 4.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}
