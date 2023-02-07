import 'dart:math';

extension Round on double {
  double roundDouble(int places) {
    num mod = pow(10.0, places);
    return ((this * mod).roundToDouble() / mod);
  }
}