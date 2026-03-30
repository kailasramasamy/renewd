import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RenewdTextStyles {
  RenewdTextStyles._();

  static TextStyle get h1 => GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => GoogleFonts.manrope(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );

  static TextStyle get h3 => GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      );

  static TextStyle get body => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodySmall => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  static TextStyle get subtitle => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle get caption => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      );

  /// Uppercase section headers (e.g., "OVERDUE", "THIS WEEK", "GET STARTED")
  static TextStyle get sectionHeader => GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      );

  static TextStyle get numberLarge => GoogleFonts.manrope(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      );

  static TextStyle get numberMedium => GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      );
}
