import 'package:flutter/material.dart';

// A sua cor de fundo. Corrigi o código hexadecimal para o que estava na sua documentação.
const Color appBackgroundColor = Color(0xFFD9D9D9);

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: appBackgroundColor,
  
  appBarTheme: const AppBarTheme(
    backgroundColor: appBackgroundColor,
    elevation: 0,
  ),

  // MUDANÇA AQUI: Corrigido de `CardTheme` para `CardThemeData`.
  cardTheme: const CardThemeData(
    color: appBackgroundColor,
    elevation: 1, // Adicionei uma leve elevação para os cards se destacarem.
  ),
);