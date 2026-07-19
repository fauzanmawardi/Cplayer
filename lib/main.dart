import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/app_theme.dart';
import 'views/screens/main_navigation_screen.dart';
import 'views/widgets/themed_background.dart';

void main() {
  runApp(const ProviderScope(child: CPlayerApp()));
}

class CPlayerApp extends StatelessWidget {
  const CPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPlayer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Bungkus semua screen otomatis, cukup sekali di sini
      builder: (context, child) {
        return ThemedBackground(child: child ?? const SizedBox());
      },
      home: const MainNavigationScreen(),
    );
  }
}