import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A calm gradient background for the wallpaper.
class WallpaperBackground {
  const WallpaperBackground({
    required this.name,
    required this.colors,
    required this.textColor,
    required this.subtleColor,
    required this.accentColor,
  });

  final String name;
  final List<Color> colors;
  final Color textColor;
  final Color subtleColor;
  final Color accentColor;

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      );
}

const wallpaperBackgrounds = <WallpaperBackground>[
  WallpaperBackground(
    name: 'Amrit vela',
    colors: [Color(0xFF07101C), Color(0xFF13263F), Color(0xFF223B5C)],
    textColor: Color(0xFFF3F4F6),
    subtleColor: Color(0xFFB4C2D3),
    accentColor: Color(0xFFC9A24A),
  ),
  WallpaperBackground(
    name: 'Sarovar',
    colors: [Color(0xFF062A2E), Color(0xFF0B4A4F), Color(0xFF16706F)],
    textColor: Color(0xFFF1F7F6),
    subtleColor: Color(0xFFB5D3D0),
    accentColor: Color(0xFFE2C478),
  ),
  WallpaperBackground(
    name: 'Kesri',
    colors: [Color(0xFF7A3305), Color(0xFFC2600F), Color(0xFFE8963A)],
    textColor: Color(0xFFFFF8EE),
    subtleColor: Color(0xFFFBE0C2),
    accentColor: Color(0xFFFFF1D6),
  ),
  WallpaperBackground(
    name: 'Marble',
    colors: [Color(0xFFF7F8F9), Color(0xFFE6E9EC), Color(0xFFD5DAE0)],
    textColor: Color(0xFF1C2532),
    subtleColor: Color(0xFF4F5B6B),
    accentColor: Color(0xFF9C7A2C),
  ),
  WallpaperBackground(
    name: 'Gold leaf',
    colors: [Color(0xFF2B1E08), Color(0xFF5A4013), Color(0xFF8C6A26)],
    textColor: Color(0xFFFFF6E0),
    subtleColor: Color(0xFFE8D6AE),
    accentColor: Color(0xFFF0CD7A),
  ),
  WallpaperBackground(
    name: 'Neela',
    colors: [Color(0xFF040B2E), Color(0xFF0B1F6B), Color(0xFF1B3A9E)],
    textColor: Color(0xFFF0F3FF),
    subtleColor: Color(0xFFB8C4EE),
    accentColor: Color(0xFFD8B865),
  ),
  WallpaperBackground(
    name: 'Night',
    colors: [Color(0xFF000000), Color(0xFF0A0A0C), Color(0xFF17171B)],
    textColor: Color(0xFFEDEDED),
    subtleColor: Color(0xFFA3A3A8),
    accentColor: Color(0xFFC9A24A),
  ),
];

/// A Gurmukhi font offered in the editor.
class GurmukhiFont {
  const GurmukhiFont({required this.label, required this.style});

  final String label;
  final TextStyle Function({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) style;
}

final gurmukhiFonts = <GurmukhiFont>[
  GurmukhiFont(
    label: 'Classic',
    style: ({fontSize, color, fontWeight, height}) => GoogleFonts.notoSerifGurmukhi(
        fontSize: fontSize, color: color, fontWeight: fontWeight, height: height),
  ),
  GurmukhiFont(
    label: 'Clean',
    style: ({fontSize, color, fontWeight, height}) => GoogleFonts.notoSansGurmukhi(
        fontSize: fontSize, color: color, fontWeight: fontWeight, height: height),
  ),
  GurmukhiFont(
    label: 'Soft',
    style: ({fontSize, color, fontWeight, height}) => GoogleFonts.muktaMahee(
        fontSize: fontSize, color: color, fontWeight: fontWeight, height: height),
  ),
  GurmukhiFont(
    label: 'Rounded',
    style: ({fontSize, color, fontWeight, height}) => GoogleFonts.balooPaaji2(
        fontSize: fontSize, color: color, fontWeight: fontWeight, height: height),
  ),
  GurmukhiFont(
    label: 'Modern',
    style: ({fontSize, color, fontWeight, height}) => GoogleFonts.anekGurmukhi(
        fontSize: fontSize, color: color, fontWeight: fontWeight, height: height),
  ),
];

enum TextPosition {
  top('Top'),
  middle('Middle'),
  bottom('Bottom');

  const TextPosition(this.label);
  final String label;
}
