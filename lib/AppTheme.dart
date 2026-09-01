import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color.fromARGB(255, 250, 250, 249),
    colorScheme: ColorScheme.light(
      primary: Color.fromARGB(255, 218, 0, 0),
      onPrimary: Color.fromARGB(255, 28, 25, 23),
      secondary: Color.fromARGB(255, 219, 182, 58),
      onSecondary: Color.fromARGB(255, 28, 25, 23),
      tertiary: Color.fromARGB(255, 211, 211, 209),
      surface: Color.fromARGB(135, 255, 221, 180),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 250, 250, 249),
      foregroundColor: Color.fromARGB(255, 219, 182, 58),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 218, 0, 0),
        foregroundColor: Color.fromARGB(255, 250, 250, 249),
      ),
    ),
    textTheme: TextTheme(
      titleMedium: TextStyle(
        color: Color.fromARGB(255, 28, 25, 23),
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(color: Color(0xFF1C1917)),
    ),
  );

  static final ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color.fromARGB(255, 28, 25, 23),
    colorScheme: ColorScheme.dark(
      primary: Color.fromARGB(255, 218, 0, 0),
      onPrimary: Color.fromARGB(255, 28, 25, 23),
      secondary: Color.fromARGB(255, 219, 182, 58),
      onSecondary: Color.fromARGB(255, 28, 25, 23),
      tertiary: Color.fromARGB(255, 48, 48, 48),
      surface: Color.fromARGB(255, 56, 51, 50),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 28, 25, 23),
      foregroundColor: Color.fromARGB(255, 219, 182, 58),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 218, 0, 0),
        foregroundColor: Color.fromARGB(255, 28, 25, 23),
      ),
    ),
    textTheme: TextTheme(
      titleMedium: TextStyle(
        color: Color.fromARGB(255, 250, 250, 249),
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(color: Color.fromARGB(255, 250, 250, 249)),
    ),
  );
}
