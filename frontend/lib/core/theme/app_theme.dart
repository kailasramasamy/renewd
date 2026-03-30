import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class RenewdTheme {
  RenewdTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: RenewdColors.softWhite,
        colorScheme: const ColorScheme.light(
          primary: RenewdColors.oceanBlue,
          secondary: RenewdColors.lavender,
          surface: RenewdColors.softWhite,
          error: RenewdColors.coralRed,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: RenewdColors.deepNavy,
          onError: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: RenewdColors.softWhite,
          foregroundColor: RenewdColors.deepNavy,
          centerTitle: false,
          titleTextStyle: RenewdTextStyles.h3.copyWith(
            color: RenewdColors.deepNavy,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: RenewdColors.oceanBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            textStyle: RenewdTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: RenewdColors.oceanBlue,
          unselectedItemColor: RenewdColors.slate,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: RenewdColors.cloudGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: RenewdColors.oceanBlue,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: RenewdColors.coralRed),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dividerTheme: const DividerThemeData(
          color: RenewdColors.mist,
          thickness: 0.5,
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        textTheme: GoogleFonts.manropeTextTheme(),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: RenewdColors.charcoal,
        colorScheme: const ColorScheme.dark(
          primary: RenewdColors.oceanBlue,
          secondary: RenewdColors.lavender,
          surface: RenewdColors.darkSlate,
          error: RenewdColors.coralRed,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: RenewdColors.warmWhite,
          onError: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: RenewdColors.charcoal,
          foregroundColor: RenewdColors.warmWhite,
          centerTitle: false,
          titleTextStyle: RenewdTextStyles.h3.copyWith(
            color: RenewdColors.warmWhite,
          ),
          iconTheme: const IconThemeData(color: RenewdColors.warmWhite),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          color: RenewdColors.darkSlate,
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: RenewdColors.oceanBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            textStyle: RenewdTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: RenewdColors.charcoal,
          selectedItemColor: RenewdColors.oceanBlue,
          unselectedItemColor: RenewdColors.warmGray,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: RenewdColors.steel,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: RenewdColors.oceanBlue,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: RenewdColors.coralRed),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: const TextStyle(color: RenewdColors.warmGray),
          hintStyle: TextStyle(
            color: RenewdColors.warmGray.withValues(alpha: 0.6),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: RenewdColors.darkBorder,
          thickness: 0.5,
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: RenewdColors.steel,
          selectedColor: RenewdColors.oceanBlue.withValues(alpha: 0.15),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: RenewdColors.darkSlate,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: RenewdColors.darkSlate,
        ),
        textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
      );
}
