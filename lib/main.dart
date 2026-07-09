import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: CplayerApp()));
}

class CplayerApp extends StatelessWidget {
  const CplayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cplayer',
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}