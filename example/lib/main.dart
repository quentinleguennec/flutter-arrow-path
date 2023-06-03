import 'dart:math' as math;

import 'package:arrow_path/arrow_path.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Arrow Path Example',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const ExampleApp(),
      );
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Arrow Path Example'),
        ),
        body: SingleChildScrollView(
          child: ClipRect(
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 700),
              painter: ArrowPainter(),
            ),
          ),
        ),
      );
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    /// The arrows usually looks better with rounded caps.
    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0;

    /// Draw a single arrow.
    {
      Path path = Path();
      path.moveTo(size.width * 0.25, 60);
      path.relativeCubicTo(0, 0, size.width * 0.25, 50, size.width * 0.5, 0);
      path = ArrowPath.addTip(path);

      canvas.drawPath(path, paint..color = Colors.blue);

      const TextSpan textSpan = TextSpan(
        text: 'Single arrow',
        style: TextStyle(color: Colors.blue),
      );
      final TextPainter textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: size.width);
      textPainter.paint(canvas, const Offset(0, 36));
    }

    /// Draw a double sided arrow.
    {
      Path path = Path();
      path.moveTo(size.width * 0.25, 120);
      path.relativeCubicTo(0, 0, size.width * 0.25, 50, size.width * 0.5, 0);
      path = ArrowPath.addTip(path);
      path = ArrowPath.addTip(path, isBackward: true);

      canvas.drawPath(path, paint..color = Colors.cyan);

      const TextSpan textSpan = TextSpan(
        text: 'Double sided arrow',
        style: TextStyle(color: Colors.cyan),
      );
      final TextPainter textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: size.width);
      textPainter.paint(canvas, const Offset(0, 96));
    }

    /// Use complex path.
    {
      Path path = Path();
      path.moveTo(size.width * 0.25, 180);
      path.relativeCubicTo(0, 0, size.width * 0.25, 50, size.width * 0.5, 50);
      path.relativeCubicTo(0, 0, -size.width * 0.25, 0, -size.width * 0.5, 50);
      path.relativeCubicTo(0, 0, size.width * 0.125, 10, size.width * 0.25, -10);
      path = ArrowPath.addTip(path);
      canvas.drawPath(path, paint..color = Colors.blue);

      const TextSpan textSpan = TextSpan(
        text: 'Complex path',
        style: TextStyle(color: Colors.blue),
      );
      final TextPainter textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: size.width);
      textPainter.paint(canvas, const Offset(0, 168));
    }

    /// Path with several forward arrow and one backward arrow.
    /// IMPORTANT: You should never use more than a single backward arrow on the same path, or the results
    /// may be unpredictable due to limitations of the Path API.
    ///
    /// If you need to build a complex path with several backward arrows then use sub-paths and
    /// merge them with Path.addPath (see after).
    {
      Path path = Path();
      path.moveTo(size.width * 0.25, 358);
      path.relativeLineTo(size.width * 0.13, 50);
      path = ArrowPath.addTip(path, tipAngle: math.pi * 0.1);
      path.relativeLineTo(size.width * 0.13, -50);
      path = ArrowPath.addTip(path, tipAngle: math.pi * 0.1);
      path.relativeLineTo(size.width * 0.08, 50);
      path = ArrowPath.addTip(path, tipAngle: math.pi * 0.1);
      path.relativeLineTo(size.width * 0.08, -50);
      path = ArrowPath.addTip(path, tipAngle: math.pi * 0.1);
      path.relativeLineTo(size.width * 0.04, 50);
      path = ArrowPath.addTip(path, tipAngle: math.pi * 0.1);
      path.relativeLineTo(size.width * 0.04, -50);
      path = ArrowPath.addTip(path, tipAngle: math.pi * 0.1);
      path = ArrowPath.addTip(path, tipAngle: math.pi * 0.1, isBackward: true);

      canvas.drawPath(path, paint..color = Colors.cyan);

      const TextSpan textSpan = TextSpan(
        text: 'Single Path with multiple forward and one backward arrow tips.',
        style: TextStyle(color: Colors.cyan),
      );
      final TextPainter textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: size.width);
      textPainter.paint(canvas, const Offset(0, 326));
    }

    /// Path with several backward arrow and one forward arrow.
    /// IMPORTANT: Due to limitations of the Path API this can only be achieved reliably by using sub-paths.
    {
      Path path = Path();
      Offset penPosition = Offset(size.width * 0.25, 470);
      path.moveTo(penPosition.dx, penPosition.dy);
      penPosition += Offset(size.width * 0.13, 50);
      path.lineTo(penPosition.dx, penPosition.dy);
      path = ArrowPath.addTip(path, tipAngle: math.pi * 0.1, isBackward: true);

      Path subPath = Path();
      subPath.moveTo(penPosition.dx, penPosition.dy);
      penPosition += Offset(size.width * 0.13, -50);
      subPath.lineTo(penPosition.dx, penPosition.dy);
      subPath = ArrowPath.addTip(subPath, tipAngle: math.pi * 0.1, isBackward: true);
      path.addPath(subPath, Offset.zero);

      subPath = Path();
      subPath.moveTo(penPosition.dx, penPosition.dy);
      penPosition += Offset(size.width * 0.08, 50);
      subPath.lineTo(penPosition.dx, penPosition.dy);
      subPath = ArrowPath.addTip(subPath, tipAngle: math.pi * 0.1, isBackward: true);
      path.addPath(subPath, Offset.zero);

      subPath = Path();
      subPath.moveTo(penPosition.dx, penPosition.dy);
      penPosition += Offset(size.width * 0.08, -50);
      subPath.lineTo(penPosition.dx, penPosition.dy);
      subPath = ArrowPath.addTip(subPath, tipAngle: math.pi * 0.1, isBackward: true);
      path.addPath(subPath, Offset.zero);

      subPath = Path();
      subPath.moveTo(penPosition.dx, penPosition.dy);
      penPosition += Offset(size.width * 0.04, 50);
      subPath.lineTo(penPosition.dx, penPosition.dy);
      subPath = ArrowPath.addTip(subPath, tipAngle: math.pi * 0.1, isBackward: true);
      path.addPath(subPath, Offset.zero);

      subPath = Path();
      subPath.moveTo(penPosition.dx, penPosition.dy);
      penPosition += Offset(size.width * 0.04, -50);
      subPath.lineTo(penPosition.dx, penPosition.dy);
      subPath = ArrowPath.addTip(subPath, tipAngle: math.pi * 0.1, isBackward: true);
      path.addPath(subPath, Offset.zero);

      path = ArrowPath.addTip(path, tipAngle: math.pi * 0.1);

      canvas.drawPath(path, paint..color = Colors.blue);

      const TextSpan textSpan = TextSpan(
        text: 'Single Path with multiple backward arrow tips.',
        style: TextStyle(color: Colors.blue),
      );
      final TextPainter textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: size.width);
      textPainter.paint(canvas, const Offset(0, 436));
    }

    /// Adjusted
    {
      Path path = Path();
      path.moveTo(size.width * 0.1, 590);
      path.relativeCubicTo(0, 0, size.width * 0.3, 50, size.width * 0.25, 75);
      path = ArrowPath.addTip(path, isAdjusted: true);
      canvas.drawPath(path, paint..color = Colors.cyan);

      const TextSpan textSpan = TextSpan(
        text: 'Adjusted',
        style: TextStyle(color: Colors.cyan),
      );
      final TextPainter textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width * 0.2, 572));
    }

    /// Non adjusted.
    {
      Path path = Path();
      path.moveTo(size.width * 0.6, 590);
      path.relativeCubicTo(0, 0, size.width * 0.3, 50, size.width * 0.25, 75);
      path = ArrowPath.addTip(path, isAdjusted: false);

      canvas.drawPath(path, paint..color = Colors.cyan);

      const TextSpan textSpan = TextSpan(
        text: 'Non adjusted',
        style: TextStyle(color: Colors.cyan),
      );
      final TextPainter textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width * 0.65, 572));
    }
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) => false;
}
