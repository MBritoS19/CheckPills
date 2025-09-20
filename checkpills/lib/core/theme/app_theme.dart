import 'package:flutter/material.dart';

// A sua cor de fundo. Corrigi o código hexadecimal para o que estava na sua documentação.
const Color appBackgroundColor = Color(0xFFD9D9D9);
const Color orangeColor = Color(0xFFF2994A);

// Renomeie o appTheme existente para lightTheme
final ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: appBackgroundColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: appBackgroundColor,
    elevation: 0,
    foregroundColor: Colors.black,
  ),
  cardTheme: const CardThemeData(
    // <-- CORRIGIDO AQUI
    color: Colors.white,
    elevation: 1,
  ),
  brightness: Brightness.light,
);

// ADICIONE ESTE NOVO TEMA ESCURO
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],
    elevation: 0,
    foregroundColor: Colors.white,
  ),
  cardTheme: CardThemeData(
    // <-- CORRIGIDO AQUI
    color: Colors.grey[850],
    elevation: 1,
  ),
);
