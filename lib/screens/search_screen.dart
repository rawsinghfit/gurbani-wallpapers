import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/verse.dart';
import '../services/banidb_service.dart';
import '../theme.dart';
import 'editor_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _service = BaniDbService();
  final _controller = TextEditingController();
  Timer? _debounce;

  SearchMode _mode = SearchMode.firstLetters;
  List<Verse> _results = const [];
  bool _loading = false;
  String? _error;
  bool _hasSearched = false;
  String _resultsLabel = '';

  // Ignores replies to searches that have since been replaced.
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _search);
  }

  Future<void> _search() async {
    _debounce?.cancel();
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() {
        _requestId++;
        _results = const [];
        _error = null;
        _loading = false;
        _hasSearched = false;
      });
      return;
    }
    await _run(() => _service.search(query, _mode), 'Results');
  }

  Future<void> _random() async {
    _debounce?.cancel();
    FocusScope.of(context).unfocus();
    await _run(_service.randomShabad, 'Random shabad');
  }

  Future<void> _run(Future<List<Verse>> Function() load, String label) async {
    final id = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
      _hasSearched = true;
    });
    try {
      final results = await load();
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = results;
        _resultsLabel = label;
        _loading = false;
      });
    } on BaniDbException catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _error = e.message;
        _results = const [];
        _loading = false;
      });
    }
  }

  void _retry() {
    if (_resultsLabel == 'Random shabad' && _controller.text.trim().isEmpty) {
      _random();
    } else {
      _search();
    }
  }

  void _showInfo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: const Text('About the Gurbani text'),
        content: const Text(
          'All Gurbani in this app comes live from BaniDB, the open Gurbani '
          'database by Khalis Foundation, and is shown exactly as it is '
          'received.\n\n'
          'Out of respect, the text can never be edited. You can only change '
          'the background, font, size and position of your wallpaper.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _open(Verse verse) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EditorScreen(verse: verse)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gurbani Wallpapers'),
        actions: [
          IconButton(
            tooltip: 'About the Gurbani text',
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Find a line of Gurbani and turn it into a wallpaper or status.',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _controller,
                        onChanged: _onChanged,
                        onSubmitted: (_) => _search(),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          helperText: 'Type in English letters or Gurmukhi',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _controller.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear',
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _controller.clear();
                                    _search();
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<SearchMode>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                              value: SearchMode.firstLetters,
                              label: Text('First letters'),
                            ),
                            ButtonSegment(
                              value: SearchMode.wholeWords,
                              label: Text('Whole words'),
                            ),
                          ],
                          selected: {_mode},
                          onSelectionChanged: (s) {
                            setState(() => _mode = s.first);
                            if (_controller.text.trim().isNotEmpty) {
                              _search();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : _random,
                          icon: const Icon(Icons.shuffle, size: 18),
                          label: const Text('Random shabad'),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: _body(textTheme)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(TextTheme textTheme) {
    if (_loading) {
      return const _Message(
        icon: null,
        title: 'Searching BaniDB…',
        child: Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_error != null) {
      return _Message(
        icon: Icons.wifi_off_rounded,
        title: _error!,
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: FilledButton(onPressed: _retry, child: const Text('Try again')),
        ),
      );
    }
    if (!_hasSearched) {
      return const _Message(
        icon: Icons.auto_awesome_outlined,
        title: 'Search by the first letter of each word, or try a random shabad.',
      );
    }
    if (_results.isEmpty) {
      return const _Message(
        icon: Icons.search_off_rounded,
        title: 'No lines found. Try different letters or switch to whole words.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _results.length + 1,
      separatorBuilder: (_, i) => SizedBox(height: i == 0 ? 4 : 10),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$_resultsLabel · tap a line to make a wallpaper',
              style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
            ),
          );
        }
        return _VerseTile(verse: _results[i - 1], onTap: _open);
      },
    );
  }
}

class _VerseTile extends StatelessWidget {
  const _VerseTile({required this.verse, required this.onTap});

  final Verse verse;
  final ValueChanged<Verse> onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(verse),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      verse.gurmukhi,
                      style: GoogleFonts.notoSansGurmukhi(
                        fontSize: 19,
                        height: 1.5,
                        color: AppColors.marble,
                      ),
                    ),
                    if (verse.transliteration.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        verse.transliteration,
                        style: textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                    if (verse.reference.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        verse.reference,
                        style: textTheme.labelSmall
                            ?.copyWith(color: AppColors.gold),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, this.child});

  final IconData? icon;
  final String title;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 40, color: AppColors.muted),
              const SizedBox(height: 12),
            ],
            if (icon == null && child != null) child!,
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.muted),
            ),
            if (icon != null && child != null) child!,
          ],
        ),
      ),
    );
  }
}
