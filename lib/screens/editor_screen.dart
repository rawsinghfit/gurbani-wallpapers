import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import '../ads/ads.dart';
import '../models/verse.dart';
import '../theme.dart';
import '../wallpaper/wallpaper_canvas.dart';
import '../wallpaper/wallpaper_style.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, required this.verse});

  final Verse verse;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _canvasKey = GlobalKey();

  int _background = 0;
  int _font = 0;
  double _textScale = 1.0;
  TextPosition _position = TextPosition.middle;
  bool _showPronunciation = true;
  bool _showMeaning = false;
  bool _busy = false;

  /// Saving and sharing unlock after one rewarded ad (Android app only).
  bool _unlocked = !rewardedAdsEnabled;

  static final _canSaveToGallery =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    preloadRewardedAd();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _ensureUnlocked() async {
    if (_unlocked) return true;
    final result = await showRewardedAd();
    if (!mounted) return false;
    if (result == RewardResult.skipped) {
      _toast('Watch the whole video to unlock your wallpaper.');
      return false;
    }
    // Earned, or no ad was available: never leave the user stuck.
    setState(() => _unlocked = true);
    return true;
  }

  Future<Uint8List> _capture() async {
    final boundary =
        _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw StateError('Preview not ready');

    final image = await boundary.toImage(pixelRatio: 4);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) throw StateError('Could not encode image');
    return data.buffer.asUint8List();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (await _ensureUnlocked()) await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() => _run(() async {
    try {
      if (!await Gal.requestAccess()) {
        _toast('Allow access to Photos to save your wallpaper.');
        return;
      }
      final bytes = await _capture();
      await Gal.putImageBytes(
        bytes,
        name: 'gurbani-wallpaper-${DateTime.now().millisecondsSinceEpoch}',
      );
      _toast(
        "Saved to your gallery. Set it as wallpaper from your phone's settings.",
      );
    } catch (_) {
      _toast("Couldn't save the wallpaper. Please try again.");
    }
  });

  Future<void> _share(BuildContext buttonContext) {
    final box = buttonContext.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    return _run(() async {
      try {
        final bytes = await _capture();
        const fileName = 'gurbani-wallpaper.png';
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(bytes, mimeType: 'image/png', name: fileName),
            ],
            fileNameOverrides: const [fileName],
            sharePositionOrigin: origin,
          ),
        );
      } catch (_) {
        _toast("Couldn't create the wallpaper. Please try again.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Make wallpaper')),
      bottomNavigationBar: const AdBanner(),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            if (wide) {
              return Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _preview(),
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(8, 16, 24, 32),
                      children: _controls(),
                    ),
                  ),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                SizedBox(
                  height: (constraints.maxHeight * 0.62).clamp(320.0, 620.0),
                  child: _preview(),
                ),
                const SizedBox(height: 16),
                ..._controls(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _preview() {
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 30,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: RepaintBoundary(
              key: _canvasKey,
              child: WallpaperCanvas(
                verse: widget.verse,
                background: wallpaperBackgrounds[_background],
                font: gurmukhiFonts[_font],
                textScale: _textScale,
                position: _position,
                showPronunciation: _showPronunciation,
                showMeaning: _showMeaning,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _controls() {
    final textTheme = Theme.of(context).textTheme;
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
      child: Text(
        text,
        style: textTheme.titleSmall?.copyWith(color: AppColors.muted),
      ),
    );

    return [
      heading('Background'),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < wallpaperBackgrounds.length; i++)
            _BackgroundSwatch(
              background: wallpaperBackgrounds[i],
              selected: i == _background,
              onTap: () => setState(() => _background = i),
            ),
        ],
      ),
      heading('Font'),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < gurmukhiFonts.length; i++)
            ChoiceChip(
              label: Text(gurmukhiFonts[i].label),
              selected: i == _font,
              onSelected: (_) => setState(() => _font = i),
            ),
        ],
      ),
      heading('Text size  ·  ${(_textScale * 100).round()}%'),
      Slider(
        value: _textScale,
        min: 0.7,
        max: 1.4,
        divisions: 14,
        label: '${(_textScale * 100).round()}%',
        onChanged: (v) => setState(() => _textScale = v),
      ),
      heading('Position'),
      SegmentedButton<TextPosition>(
        showSelectedIcon: false,
        segments: [
          for (final p in TextPosition.values)
            ButtonSegment(value: p, label: Text(p.label)),
        ],
        selected: {_position},
        onSelectionChanged: (s) => setState(() => _position = s.first),
      ),
      const SizedBox(height: 12),
      SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: const Text('Show pronunciation'),
        value: _showPronunciation,
        onChanged: widget.verse.transliteration.isEmpty
            ? null
            : (v) => setState(() => _showPronunciation = v),
      ),
      SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: const Text('Show English meaning'),
        value: _showMeaning,
        onChanged: widget.verse.meaning.isEmpty
            ? null
            : (v) => setState(() => _showMeaning = v),
      ),
      const SizedBox(height: 16),
      ..._actions(textTheme),
    ];
  }

  List<Widget> _actions(TextTheme textTheme) {
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      textStyle: textTheme.titleMedium,
    );
    const spinner = SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
    Widget hint(String text) => Text(
      text,
      textAlign: TextAlign.center,
      style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
    );

    final shareButton = Builder(
      builder: (buttonContext) => _canSaveToGallery
          ? OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _busy ? null : () => _share(buttonContext),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share to WhatsApp, Instagram…'),
            )
          : FilledButton.icon(
              style: buttonStyle,
              onPressed: _busy ? null : () => _share(buttonContext),
              icon: _busy ? spinner : const Icon(Icons.ios_share),
              label: Text(_busy ? 'Preparing…' : 'Share wallpaper'),
            ),
    );

    if (!_canSaveToGallery) {
      return [
        shareButton,
        const SizedBox(height: 12),
        hint(
          "Tip: Choose 'Save image' in the share menu, then set it as your "
          "wallpaper from your phone's settings.",
        ),
      ];
    }

    return [
      FilledButton.icon(
        style: buttonStyle,
        onPressed: _busy ? null : _save,
        icon: _busy
            ? spinner
            : Icon(_unlocked ? Icons.download_rounded : Icons.smart_display),
        label: Text(
          _busy
              ? 'Please wait…'
              : _unlocked
              ? 'Save to gallery'
              : 'Watch ad & save',
        ),
      ),
      const SizedBox(height: 10),
      shareButton,
      const SizedBox(height: 12),
      hint(
        _unlocked
            ? "Saved wallpapers go to your gallery. Set one as your wallpaper "
                  "from your phone's settings."
            : 'Watch a short video ad to unlock saving and sharing for this '
                  'wallpaper.',
      ),
    ];
  }
}

class _BackgroundSwatch extends StatelessWidget {
  const _BackgroundSwatch({
    required this.background,
    required this.selected,
    required this.onTap,
  });

  final WallpaperBackground background;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: background.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: background.gradient,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppColors.gold : const Color(0xFF2E425A),
                    width: selected ? 2.5 : 1,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                background.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? AppColors.marble : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
