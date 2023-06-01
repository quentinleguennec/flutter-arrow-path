library arrow_path;

import 'dart:math' as math;
import 'dart:ui';

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
  ///
  /// If the given path is not suitable to draw the arrow head (for example if the path as no length) then the path will be returned unchanged.
  static Path make({
    required Path path,
    double tipLength = 15,
    double tipAngle = math.pi * 0.2,
    bool isDoubleSided = false,
    bool reverse = false,
    bool isAdjusted = true,
  }) {
    double adjustmentAngle = 0;

    final double angle = math.pi - tipAngle;
    final List<PathMetric> pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) {
      /// This can happen if the path as no length (trying to draw an arrow that is too small, like less than 1 pixel).
      return path;
    }

    Offset tipVector;
    final PathMetric lastPathMetric = pathMetrics.last;
    final Tangent? tangentLastPath = lastPathMetric.getTangentForOffset(lastPathMetric.length);
    if (tangentLastPath == null) {
      /// This should never happen.
      return path;
    }

    final Offset originalPosition = tangentLastPath.position;

    if (isDoubleSided || !reverse) {
      if (isAdjusted && lastPathMetric.length > 10) {
        final Tangent tanBefore = lastPathMetric.getTangentForOffset(lastPathMetric.length - 5)!;
        adjustmentAngle = _getAngleBetweenVectors(tangentLastPath.vector, tanBefore.vector);
      }

      tipVector = _rotateVector(tangentLastPath.vector, angle - adjustmentAngle) * tipLength;
      path.moveTo(tangentLastPath.position.dx, tangentLastPath.position.dy);
      path.relativeLineTo(tipVector.dx, tipVector.dy);

      tipVector = _rotateVector(tangentLastPath.vector, -angle - adjustmentAngle) * tipLength;
      path.moveTo(tangentLastPath.position.dx, tangentLastPath.position.dy);
      path.relativeLineTo(tipVector.dx, tipVector.dy);
    }

    final PathMetric? firstPathMetric = (isDoubleSided || reverse) ? pathMetrics.first : null;
    if (firstPathMetric != null) {
      final Tangent? tangentFirstPath = firstPathMetric.getTangentForOffset(0);
      if (tangentFirstPath != null) {
        if (isAdjusted && firstPathMetric.length > 10) {
          final Tangent tanBefore = firstPathMetric.getTangentForOffset(5)!;
          adjustmentAngle = _getAngleBetweenVectors(tangentFirstPath.vector, tanBefore.vector);
        }

        tipVector = _rotateVector(-tangentFirstPath.vector, angle - adjustmentAngle) * tipLength;
        path.moveTo(tangentFirstPath.position.dx, tangentFirstPath.position.dy);
        path.relativeLineTo(tipVector.dx, tipVector.dy);

        tipVector = _rotateVector(-tangentFirstPath.vector, -angle - adjustmentAngle) * tipLength;
        path.moveTo(tangentFirstPath.position.dx, tangentFirstPath.position.dy);
        path.relativeLineTo(tipVector.dx, tipVector.dy);
      }
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

  /// Clamp to avoid rounding issues when the 2 vectors are equal.
  static double _getAngleBetweenVectors(Offset vector1, Offset vector2) => math.acos(
        (_getVectorsDotProduct(vector1, vector2) / (vector1.distance * vector2.distance)).clamp(-1.0, 1.0),
      );
}
