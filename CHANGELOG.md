## [3.1.0] - 2023-06-02

* *DEPRECATED* Deprecated ArrowPath.make(), use ArrowPath.addTip() instead.
* Added ArrowPath.addTip(), which is the same as ArrowPath.make() but without `isDoubleSided` and with the new `isBackward` argument.
  This will allow more control on what side the arrow should be added.
* Updated README to add migration instructions.
* Updated for Flutter 3.10 and Dart 3.
* Update Example app.
* Update License wording (same license).

## [3.0.0] - 2022-07-18

* *(Potentially) Breaking change:* Updated to AndroidX.
* Fixed issue when the given path is too small (for example a 0 length path). Thanks to @Freancy for bug report.
* Example App: Added ScrollView and removed vertical screen constraint.
* Example App: Update to Android embedding V2.
* Improved code style.

## [2.0.0] - 2021-04-29

* *Breaking change:* Null safety

## [1.0.0] - 2019-05-11

* Initial release.
