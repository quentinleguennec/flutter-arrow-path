
[![pub package](https://img.shields.io/pub/v/arrow_path.svg)](https://pub.dev/packages/arrow_path)
[![pub points](https://img.shields.io/pub/points/arrow_path?color=2E8B57&label=pub%20points)](https://pub.dev/packages/arrow_path/score)


# Flutter arrow_path package

Draw arrows with Path objects easily. Paths can be composited to add arrows to any curve and draw all at once.


<p align="center">
    <img src="https://raw.githubusercontent.com/quentinleguennec/flutter-arrow-path/master/example/arrow_path_example.png" width="400" align="middle"/>
</p>


The arrow is drawn using the direction of the tangent to the curve at the end of the curve.
It features an adjustment parameter to also look at the tangent just before the end of the
segment and rotate the tip of the arrow based on the angle difference to improve the look of the arrow
when the curvature at the end is high.

## Getting Started

Have a look at the [example app](https://github.com/quentinleguennec/flutter-arrow-path/blob/master/example/lib/main.dart) to get started.

## Migration from [3.0.0] to [3.1.0]

ArrowPath.make() is now deprecated, use ArrowPath.addTip() instead.


If you are not using the `isDoubleSided` argument of ArrowPath.make() then you can safely replace it by ArrowPath.addTip() without any other change.


If you are using the `isDoubleSided`  argument of ArrowPath.make() then change yor code like this:


Before:
```dart
  Path path = Path();
  path.relativeLineTo(100, 100);
  path = ArrowPath.make(path, isDoubleSided: true);
```

After:
```dart
  Path path = Path();
  path.relativeLineTo(100, 100);
  path = ArrowPath.addTip(path);
  path = ArrowPath.addTip(path, isBackward: true);
```