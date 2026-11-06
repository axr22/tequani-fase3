import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores basada en tu diseño
  static const Color obsidianBlack = Color(0xFF14110F); // Fondo base
  static const Color deepJadeGreen = Color(0xFF1B4D3E); // Botón secundario[cite: 1]
  static const Color tezontleRed   = Color(0xFF7A1C1C); // Botón de acción principal / CTA[cite: 1]
  static const Color ochreGold     = Color(0xFFC29B38); // Títulos, bordes e íconos[cite: 1]
  static const Color amatePaper    = Color(0xFFE5D4C0); // Texto principal y legibilidad[cite: 1]

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: obsidianBlack,
    colorScheme: const ColorScheme.dark(
      primary: tezontleRed,
      secondary: deepJadeGreen,
      surface: obsidianBlack,
      onSurface: amatePaper,
      tertiary: ochreGold,
    ),
    // Estilo para la barra superior
    appBarTheme: const AppBarTheme(
      backgroundColor: obsidianBlack,
      foregroundColor: amatePaper,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: ochreGold,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    // Estilo del texto predeterminado
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: amatePaper),
      bodyMedium: TextStyle(color: amatePaper),
      titleLarge: TextStyle(color: ochreGold, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: ochreGold),
    ),
    // Botón Principal (Tezontle Red)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tezontleRed,
        foregroundColor: amatePaper,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: ochreGold, width: 1), // Borde elegante en oro
        ),
      ),
    ),
    // Botón Secundario (Deep Jade Green)
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: deepJadeGreen,
        foregroundColor: amatePaper,
        side: const BorderSide(color: ochreGold, width: 1),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    // Estilo de los campos de texto de formularios (inputs)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1F1A17), // Un tono ligeramente más claro para contraste
      labelStyle: const TextStyle(color: amatePaper),
      hintStyle: TextStyle(color: amatePaper.withOpacity(0.6)),
      prefixIconColor: ochreGold,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ochreGold),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: tezontleRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    ),
  );
}