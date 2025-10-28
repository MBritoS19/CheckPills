import 'package:flutter/material.dart';

// 1. DEFINIÇÃO DAS CORES PRINCIPAIS DO APP
const Color _primaryBlue = Color(0xFF23AFDC);
const Color _accentOrange = Color(0xFFDC5023);
const Color _lightGreyBackground = Color(0xFFD9D9D9);

// 2. DEFINIÇÃO DO NOSSO ESQUEMA DE CORES CLARO
const ColorScheme _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: _primaryBlue,
  onPrimary: Colors.white,
  secondary: _accentOrange,
  onSecondary: Colors.white,
  error: Colors.redAccent,
  onError: Colors.white,
  surface: Colors.white,
  onSurface: Colors.black,
);

// 3. DEFINIÇÃO DO NOSSO ESQUEMA DE CORES ESCURO
const ColorScheme _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: _primaryBlue,
  onPrimary: Colors.white,
  secondary: _accentOrange,
  onSecondary: Colors.white,
  error: Colors.redAccent,
  onError: Colors.white,
  surface: Color(0xFF1E1E1E),
  onSurface: Colors.white,
);

// 4. CONFIGURAÇÃO FINAL DO TEMA CLARO
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _lightColorScheme,
  scaffoldBackgroundColor: _lightGreyBackground,
  appBarTheme: const AppBarTheme(
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: _lightColorScheme.surface,
    elevation: 1,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: _lightColorScheme.primary,
    foregroundColor: _lightColorScheme.onPrimary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);

// 5. CONFIGURAÇÃO FINAL DO TEMA ESCURO
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _darkColorScheme,
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: _darkColorScheme.surface,
    elevation: 1,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: _darkColorScheme.primary,
    foregroundColor: _darkColorScheme.onPrimary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);