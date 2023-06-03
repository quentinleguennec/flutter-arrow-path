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
  @Deprecated('This is deprecated and will be removed in a future release. Use ArrowPath.addTip instead.')
  static Path make({
    required Path path,
    double tipLength = 15,
    double tipAngle = math.pi * 0.2,
    bool isDoubleSided = false,
    bool isAdjusted = true,
  }) {
    final List<PathMetric> pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) {
      /// This can happen if the path as no length (trying to draw an arrow that is too small, like less than 1 pixel).
      return path;
    }

    tipAngle = math.pi - tipAngle;
    final PathMetric lastPathMetric = pathMetrics.last;
    final PathMetric firstPathMetric = pathMetrics.first;

    final Tangent? tangentLastPath = lastPathMetric.getTangentForOffset(lastPathMetric.length);

    if (tangentLastPath == null) {
      /// This should never happen.
      return path;
    }

    final Offset originalPosition = tangentLastPath.position;

    double adjustmentAngle = 0;
    if (isAdjusted && lastPathMetric.length > 10) {
      final Tangent tanBefore = lastPathMetric.getTangentForOffset(lastPathMetric.length - 5)!;
      adjustmentAngle = _getAngleBetweenVectors(tangentLastPath.vector, tanBefore.vector);
    }

    _addFullArrowTip(
      path: path,
      tangentVector: tangentLastPath.vector,
      tangentPosition: tangentLastPath.position,
      tipLength: tipLength,
      tipAngle: tipAngle,
      adjustmentAngle: adjustmentAngle,
    );

    if (isDoubleSided) {
      /// This path is double side, add the other arrow tip.
      final Tangent? tangentFirstPath = firstPathMetric.getTangentForOffset(0);
      if (tangentFirstPath != null) {
        if (isAdjusted && firstPathMetric.length > 10) {
          final Tangent tanBefore = firstPathMetric.getTangentForOffset(5)!;
          adjustmentAngle = _getAngleBetweenVectors(tangentFirstPath.vector, tanBefore.vector);
        }

        _addFullArrowTip(
          path: path,
          tangentVector: -tangentFirstPath.vector,
          tangentPosition: tangentFirstPath.position,
          tipLength: tipLength,
          tipAngle: tipAngle,
          adjustmentAngle: adjustmentAngle,
        );
      }
    }

    path.moveTo(originalPosition.dx, originalPosition.dy);

    return path;
  }

  /// Add an arrow to the end of the last drawn curve in the given path.
  ///
  /// The returned path is moved to the end of the curve. Always add the arrow before moving the path, not after, else the move will be lost.
  /// After adding the arrow you can move the path, draw more and apply an arrow to the new drawn part.
  ///
  /// If [isBackward] is true (default to false), the arrow will be added to the beginning of the first drawn curve instead of the end.
  /// This should never be called more than once on the same path. If you want to make a path with several backward arrows then use sub-paths and
  /// merge them with [Path.addPath].
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
  static Path addTip(
    Path path, {
    double tipLength = 15,
    double tipAngle = math.pi * 0.2,
    bool isBackward = false,
    bool isAdjusted = true,
  }) {
    path = Path.from(path);

    final List<PathMetric> pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) {
      /// This can happen if the path as no length (trying to draw an arrow that is too small, like less than 1 pixel).
      return path;
    }

    final Offset? originalPosition = _getPathEndPosition(pathMetrics);
    if (originalPosition == null) {
      /// This should never happen.
      return path;
    }

    tipAngle = math.pi - tipAngle;
    final PathMetric pathMetric = isBackward ? pathMetrics.first : pathMetrics.last;

    final Tangent? tangent = pathMetric.getTangentForOffset(isBackward ? 0 : pathMetric.length);
    if (tangent == null) {
      /// This should never happen.
      return path;
    }

    double adjustmentAngle = 0;
    if (isAdjusted && pathMetric.length > 10) {
      final Tangent tangentBefore = pathMetric.getTangentForOffset(isBackward ? 5 : pathMetric.length - 5)!;
      adjustmentAngle = _getAngleBetweenVectors(tangent.vector, tangentBefore.vector);
    }

    if (isBackward) {
      /// Using a temporary [Path] and [Path.addPath] because we want the backward arrow to always be at the start of the [PathMetrics].
      /// This is important because calling [Path.moveTo] does NOT actually create a segment, so the move information is lost we next read [PathMetrics].
      /// See [_getPathEndPosition] for more info.
      final tempoPath = Path();

      tempoPath.moveTo(tangent.position.dx, tangent.position.dy);

      _addFullArrowTip(
        path: tempoPath,
        tangentVector: -tangent.vector,
        tangentPosition: tangent.position,
        tipLength: tipLength,
        tipAngle: tipAngle,
        adjustmentAngle: adjustmentAngle,
      );
      tempoPath.addPath(path, Offset.zero);
      return tempoPath;
    } else {
      _addFullArrowTip(
        path: path,
        tangentVector: tangent.vector,
        tangentPosition: tangent.position,
        tipLength: tipLength,
        tipAngle: tipAngle,
        adjustmentAngle: adjustmentAngle,
      );
    }

    return path;
  }

  static void _addFullArrowTip({
    required Path path,
    required Offset tangentVector,
    required Offset tangentPosition,
    required double tipLength,
    required double tipAngle,
    required double adjustmentAngle,
  }) {
    _addPartialArrowTip(
      tangentVector: tangentVector,
      tangentPosition: tangentPosition,
      path: path,
      tipLength: tipLength,
      tipAngle: tipAngle,
      adjustmentAngle: adjustmentAngle,
    );
    _addPartialArrowTip(
      tangentVector: tangentVector,
      tangentPosition: tangentPosition,
      path: path,
      tipLength: tipLength,
      tipAngle: -tipAngle,
      adjustmentAngle: adjustmentAngle,
    );
  }

  /// We need to make sure we end by drawing back to the start position, because simply doing a moveTo does NOT save to
  /// the [PathMetrics], so the move is lost and this causes issues for successive arrow tip drawings.
  static void _addPartialArrowTip({
    required Path path,
    required Offset tangentVector,
    required Offset tangentPosition,
    required double tipLength,
    required double tipAngle,
    required double adjustmentAngle,
  }) {
    final Offset tipVector = _rotateVector(tangentVector, tipAngle - adjustmentAngle) * tipLength;
    path.relativeMoveTo(tipVector.dx, tipVector.dy);
    path.relativeLineTo(-tipVector.dx, -tipVector.dy);
  }

  /// Defining the Path end is tricky, ideally we would want to get the position of the last moveTo from the Path, but his is not
  /// possible (there is no way to get that from the Path API).
  /// Instead we have to use the last PathMetric (the segment that was last drawn) and hope it is what we want it to be.
  /// This would fails for example if we where adding the backward arrow directly to the end of the path, because even doing
  /// a moveTo back to the end of the path (before we added the arrow tip) would not allow us to get the right position if
  /// we try to draw a forward arrow straight after. Instead, the forward arrow would be draw at the last lineTo position (not the
  /// last moveTo position), which would happen to be at the start of the path (since it's were we last drawn something).
  /// This is why we use a temporary path to draw the backward arrow tip, and we add the path as a sub-path
  /// of the temporary path. Then we reassign the path with `path = subpath`. This allow us to have the backward arrow at
  /// the start of the PathMetrics, rather than the end, and then we can draw any following forward arrow correctly.
  static Offset? _getPathEndPosition(List<PathMetric> pathMetrics) {
    final Tangent? tangent = pathMetrics.last.getTangentForOffset(pathMetrics.last.length);

    if (tangent == null) {
      /// This should never happen.
      return null;
    }

    return tangent.position;
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
