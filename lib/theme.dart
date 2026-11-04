import 'package:flutter/material.dart';

import 'models.dart';

class C {
  static const bg = Color(0xFF0A0F24);
  static const surface = Color(0xFF121A36);
  static const border = Color(0xFF1E2A4F);
  static const text = Color(0xFFE8ECF8);
  static const muted = Color(0xFF7C88B0);
  static const blue = Color(0xFF4F8CFF);
  static const green = Color(0xFF3DDC97);
}
const double fontScale = 1.25;

Color trackerColor(Tracker t) => t == Tracker.study ? C.blue : C.green;
String trackerLabel(Tracker t) =>
    t == Tracker.study ? '📘 Study' : '🌱 Skill Development';

TextStyle mono(double size, {Color color = C.text, FontWeight? weight}) =>
    TextStyle(fontFamily: 'Pricedown', fontSize: size*fontScale, color: color, fontWeight: weight);

TextStyle syne(double size, {Color color = C.text, FontWeight? weight}) =>
    TextStyle(fontFamily: 'Pricedown', fontSize: size*fontScale, color: color, fontWeight: weight);

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: C.bg,
      colorScheme: const ColorScheme.dark(primary: C.blue, surface: C.surface),
    );