library arrow_path;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

class ArrowPath {
  /// Add an arrow to the end of the last drawn curve in the given path.
  ///
  /// The returned path is moved to the end of the curve. Always add the arrow before moving the path, not after, else the move will be lost.
  /// After adding the arrow you can move the path, draw more and apply an arrow to the new drawn part.
  ///
  /// If [isDoubleSided] is true (default to false), an arrow will also be added to the beginning of the first drawn curve.
  ///
  /// [tipLength] is the length (in pixels) of each of the 2 lines making the arrow.
  ///
  /// [tipAngle] is the angle (in radians) between each of the 2 lines making the arrow and the curve at this point.
  ///
  /// If [isAdjusted] is true (default to true), the tip of the arrow will be rotated (not following the tangent perfectly).
  /// This improves the look of the arrow when the end of the curve as a strong curvature.
  /// Can be disabled to save performance when the arrow is flat.
  static Path make({
    required Path path,
    double tipLength = 15,
    double tipAngle = math.pi * 0.2,
    bool isDoubleSided = false,
    bool isAdjusted = true,
  }) =>
      _make(path, tipLength, tipAngle, isDoubleSided, isAdjusted);

  static Path _make(Path path, double tipLength, double tipAngle,
      bool isDoubleSided, bool isAdjusted) {
    PathMetric lastPathMetric;
    PathMetric? firstPathMetric;
    Offset tipVector;
    Tangent? tan;
    double adjustmentAngle = 0;

    double angle = math.pi - tipAngle;
    lastPathMetric = path.computeMetrics().last;
    if (isDoubleSided) {
      firstPathMetric = path.computeMetrics().first;
    }

    tan = lastPathMetric.getTangentForOffset(lastPathMetric.length);

    final Offset originalPosition = tan!.position;

    if (isAdjusted && lastPathMetric.length > 10) {
      Tangent tanBefore =
          lastPathMetric.getTangentForOffset(lastPathMetric.length - 5)!;
      adjustmentAngle = _getAngleBetweenVectors(tan.vector, tanBefore.vector);
    }

    tipVector = _rotateVector(tan.vector, angle - adjustmentAngle) * tipLength;
    path.moveTo(tan.position.dx, tan.position.dy);
    path.relativeLineTo(tipVector.dx, tipVector.dy);

    tipVector = _rotateVector(tan.vector, -angle - adjustmentAngle) * tipLength;
    path.moveTo(tan.position.dx, tan.position.dy);
    path.relativeLineTo(tipVector.dx, tipVector.dy);

    if (isDoubleSided) {
      tan = firstPathMetric!.getTangentForOffset(0);
      if (isAdjusted && firstPathMetric.length > 10) {
        Tangent tanBefore = firstPathMetric.getTangentForOffset(5)!;
        adjustmentAngle = _getAngleBetweenVectors(tan!.vector, tanBefore.vector);
      }

      tipVector =
          _rotateVector(-tan!.vector, angle - adjustmentAngle) * tipLength;
      path.moveTo(tan.position.dx, tan.position.dy);
      path.relativeLineTo(tipVector.dx, tipVector.dy);

      tipVector =
          _rotateVector(-tan.vector, -angle - adjustmentAngle) * tipLength;
      path.moveTo(tan.position.dx, tan.position.dy);
      path.relativeLineTo(tipVector.dx, tipVector.dy);
    }

    path.moveTo(originalPosition.dx, originalPosition.dy);

    return path;
  }

  static Offset _rotateVector(Offset vector, double angle) => Offset(
        math.cos(angle) * vector.dx - math.sin(angle) * vector.dy,
        math.sin(angle) * vector.dx + math.cos(angle) * vector.dy,
      );

  static double _getVectorsDotProduct(Offset vector1, Offset vector2) =>
      vector1.dx * vector2.dx + vector1.dy * vector2.dy;

  // Clamp to avoid rounding issues when the 2 vectors are equal.
  static double _getAngleBetweenVectors(Offset vector1, Offset vector2) =>
      math.acos((_getVectorsDotProduct(vector1, vector2) /
              (vector1.distance * vector2.distance))
          .clamp(-1.0, 1.0));
}
