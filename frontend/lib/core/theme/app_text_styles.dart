import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RenewdTextStyles {
  RenewdTextStyles._();

  static TextStyle get h1 => GoogleFonts.publicSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => GoogleFonts.publicSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );

  static TextStyle get h3 => GoogleFonts.publicSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      );

  static TextStyle get body => GoogleFonts.publicSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodySmall => GoogleFonts.publicSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  static TextStyle get subtitle => GoogleFonts.publicSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle get caption => GoogleFonts.publicSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      );

  /// Uppercase section headers (e.g., "OVERDUE", "THIS WEEK", "GET STARTED")
  static TextStyle get sectionHeader => GoogleFonts.publicSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      );

  static TextStyle get numberLarge => GoogleFonts.publicSans(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      );

  static TextStyle get numberMedium => GoogleFonts.publicSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      );
}
