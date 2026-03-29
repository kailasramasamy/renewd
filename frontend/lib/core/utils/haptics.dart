import 'package:flutter/services.dart';

class RenewdHaptics {
  RenewdHaptics._();

  /// Light tap — button press, tab switch
  static void light() => HapticFeedback.lightImpact();

  /// Medium — successful action (save, create, mark renewed)
  static void success() => HapticFeedback.mediumImpact();

  /// Heavy — destructive action (delete), error
  static void error() => HapticFeedback.heavyImpact();

  /// Selection tick — toggle, picker change
  static void selection() => HapticFeedback.selectionClick();
}
