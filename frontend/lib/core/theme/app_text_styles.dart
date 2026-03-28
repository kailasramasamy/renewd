import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RenewdTextStyles {
  RenewdTextStyles._();

  static TextStyle get h1 => GoogleFonts.dmSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      );

  static TextStyle get h3 => GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      );

  static TextStyle get body => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySmall => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      );

  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      );

  static TextStyle get numberLarge => GoogleFonts.dmSans(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      );

  static TextStyle get numberMedium => GoogleFonts.dmSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      );
}
