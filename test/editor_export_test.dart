import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gurbani_wallpapers/models/verse.dart';
import 'package:gurbani_wallpapers/screens/editor_screen.dart';
import 'package:gurbani_wallpapers/wallpaper/wallpaper_canvas.dart';

// Placeholder text only: real Gurbani always comes from BaniDB.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('wallpaper can still be exported after scrolling to the buttons',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: EditorScreen(
          verse: Verse(gurmukhi: 'LINE'),
        ),
      ),
    );
    await tester.pump();

    await tester.dragUntilVisible(
      find.text('Save to gallery'),
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );
    await tester.pump();

    final canvas = find.byType(WallpaperCanvas, skipOffstage: false);
    expect(canvas, findsOneWidget);

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.ancestor(of: canvas, matching: find.byType(RepaintBoundary)).first,
    );
    final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 4));
    expect(image!.width, 1440);
    expect(image.height, 3120);
  });
}
