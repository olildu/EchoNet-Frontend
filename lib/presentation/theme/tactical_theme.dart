import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // NEW IMPORT

class TacticalColors {
  static const Color background = Color(0xFF131313);
  static const Color surface = Color(0xFF131313);
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);
  static const Color surfaceContainer = Color(0xFF201F1F);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);
  static const Color primary = Color(0xFFFFB59C);
  static const Color primaryContainer = Color(0xFFFF5F1F);
  static const Color secondaryContainer = Color(0xFF2FF801);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFE3BFB3);
  static const Color outlineVariant = Color(0x265B4138);

  static const LinearGradient sosGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );
}

class TacticalTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TacticalColors.background,

      colorScheme: const ColorScheme.dark(
        primary: TacticalColors.primary,
        primaryContainer: TacticalColors.primaryContainer,
        secondaryContainer: TacticalColors.secondaryContainer,
        surface: TacticalColors.surface,
        onSurface: TacticalColors.onSurface,
        errorContainer: TacticalColors.errorContainer,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 56.sp, // Scaled
          fontWeight: FontWeight.w900,
          letterSpacing: -1.5,
          color: TacticalColors.onSurface,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 28.sp, // Scaled
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: TacticalColors.primary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16.sp, // Scaled
          fontWeight: FontWeight.w400,
          color: TacticalColors.onSurface,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10.sp, // Scaled
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
          color: TacticalColors.onSurfaceVariant,
        ),
      ),

      cardTheme: CardThemeData(
        color: TacticalColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.r), // Scaled Radius
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TacticalColors.primaryContainer,
          foregroundColor: TacticalColors.background,
          textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 2),
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 32.w), // Scaled Padding
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}
