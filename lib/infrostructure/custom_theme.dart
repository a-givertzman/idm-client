import 'package:flutter/material.dart';

final ThemeData customTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF212842),
    primaryContainer: const Color(0xFF212842),
    onPrimaryContainer: const Color(0xFF747EA1),
    errorContainer: const Color(0xFFF0E7D5),
    onErrorContainer: const Color(0xFF3F0E0E),
    onSecondary: const Color(0xFFF0E7D5),
  ),
  useMaterial3: true,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 16.0, color: Color(0xFFF0E7D5))
  ),
);
