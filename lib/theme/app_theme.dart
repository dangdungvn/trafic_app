import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4D5DFA);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF212121);
  static const Color subTextColor = Color(0xFF9E9E9E);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color inputFillColor = Color(0xFFFAFAFA);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: backgroundColor,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionColor: Color(0x334D5DFA), // primaryColor with ~0.2 opacity
        selectionHandleColor: primaryColor,
      ),
      textTheme: GoogleFonts.urbanistTextTheme(),
    );
  }
}
