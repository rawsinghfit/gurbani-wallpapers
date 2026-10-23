import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/verse.dart';
import 'wallpaper_style.dart';

/// The wallpaper itself, always laid out on a fixed 360x780 canvas.
///
/// Exported at pixelRatio 4 this gives a 1440x3120 image.
class WallpaperCanvas extends StatelessWidget {
  const WallpaperCanvas({
    super.key,
    required this.verse,
    required this.background,
    required this.font,
    required this.textScale,
    required this.position,
    required this.showPronunciation,
    required this.showMeaning,
  });

  static const width = 360.0;
  static const height = 780.0;

  /// Space kept free at the top for the lock-screen clock.
  static const _clockSpace = 250.0;
  static const _bottomSpace = 90.0;
  static const _sidePadding = 32.0;

  final Verse verse;
  final WallpaperBackground background;
  final GurmukhiFont font;
  final double textScale;
  final TextPosition position;
  final bool showPronunciation;
  final bool showMeaning;

  @override
  Widget build(BuildContext context) {
    final alignment = switch (position) {
      TextPosition.top => Alignment.topCenter,
      TextPosition.middle => Alignment.center,
      TextPosition.bottom => Alignment.bottomCenter,
    };
    final topSpace = position == TextPosition.middle ? 60.0 : _clockSpace;

    return MediaQuery.withNoTextScaling(
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: background.gradient),
          child: Stack(
            children: [
              Positioned(
                left: _sidePadding,
                right: _sidePadding,
                top: topSpace,
                bottom: _bottomSpace,
                child: Align(
                  alignment: alignment,
                  // Very long lines shrink to fit rather than overflow.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: alignment,
                    child: SizedBox(
                      width: width - _sidePadding * 2,
                      child: _content(),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 30,
                child: Text(
                  'Gurbani Wallpapers',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.figtree(
                    fontSize: 9,
                    letterSpacing: 1.2,
                    color: background.subtleColor.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content() {
    final reference = verse.reference;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          verse.gurmukhi,
          textAlign: TextAlign.center,
          style: font.style(
            fontSize: 30 * textScale,
            color: background.textColor,
            fontWeight: FontWeight.w500,
            height: 1.55,
          ),
        ),
        if (showPronunciation && verse.transliteration.isNotEmpty) ...[
          SizedBox(height: 14 * textScale),
          Text(
            verse.transliteration,
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              fontSize: 14 * textScale,
              fontStyle: FontStyle.italic,
              height: 1.45,
              color: background.subtleColor,
            ),
          ),
        ],
        if (showMeaning && verse.meaning.isNotEmpty) ...[
          SizedBox(height: 12 * textScale),
          Text(
            verse.meaning,
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              fontSize: 13 * textScale,
              height: 1.45,
              color: background.subtleColor,
            ),
          ),
        ],
        if (reference.isNotEmpty) ...[
          const SizedBox(height: 22),
          Container(
            width: 36,
            height: 1.5,
            color: background.accentColor.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          Text(
            reference,
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(
              fontSize: 11,
              letterSpacing: 0.4,
              color: background.subtleColor.withValues(alpha: 0.9),
            ),
          ),
        ],
      ],
    );
  }
}
