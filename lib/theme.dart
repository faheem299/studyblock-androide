import 'package:flutter/material.dart';
import 'models.dart';

class C {
  static const bg = Color(0xFF07090F);
  static const surface = Color(0xFF161C28);
  static const border = Color(0xFF1B2333); // empty cells, bar tracks
  static const line = Color(0xFF2A3345);
  static const text = Color(0xFFF2F5F7);
  static const muted = Color(0xFFAEB8CC);
  static const lime = Color(0xFFC6FF3D);
  static const cyan = Color(0xFF2DE2E6);
  // old names, so the other files keep working
  static const blue = lime; // study
  static const green = cyan; // skill
}

const double fontScale = 1.0;

Color trackerColor(Tracker t) => t == Tracker.study ? C.lime : C.cyan;
String trackerLabel(Tracker t) => t == Tracker.study ? 'STUDY' : 'SKILL';

/// Headings, buttons, labels (Barlow Condensed, wide tracking).
TextStyle syne(double size, {Color color = C.text, FontWeight? weight}) => TextStyle(
    fontFamily: 'BarlowCondensed',
    fontSize: size * 1.2 * fontScale,
    color: color,
    fontWeight: weight ?? FontWeight.w700,
    letterSpacing: 2);

/// Body text and small numbers (Barlow).
TextStyle mono(double size, {Color color = C.text, FontWeight? weight}) => TextStyle(
    fontFamily: 'Barlow',
    fontSize: size * 1.1 * fontScale,
    color: color,
    fontWeight: weight ?? FontWeight.w500);

/// Huge numerals and statements.
TextStyle display(double size, {Color color = C.text, double spacing = -2}) => TextStyle(
    fontFamily: 'BarlowCondensed',
    fontSize: size,
    color: color,
    fontWeight: FontWeight.w800,
    height: 0.9,
    letterSpacing: spacing);

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: C.bg,
      colorScheme: const ColorScheme.dark(primary: C.lime, surface: C.surface),
    );