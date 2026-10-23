import 'package:flutter/material.dart';

import 'screens/search_screen.dart';
import 'theme.dart';

void main() {
  runApp(const GurbaniWallpapersApp());
}

class GurbaniWallpapersApp extends StatelessWidget {
  const GurbaniWallpapersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gurbani Wallpapers',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SearchScreen(),
    );
  }
}
