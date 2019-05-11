<a href="https://pub.dev/packages/arrow_path">
   <img alt="Dart Pub" src="https://img.shields.io/pub/v/arrow_path.svg?color=orange&style=flat-square" />
</a>

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