import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/navigation_controller.dart';
import '../../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'music_screen.dart';
import 'playlist_screen.dart';
import 'settings_screen.dart';
import 'video_screen.dart';

/// View: shell utama aplikasi.
/// Berisi IndexedStack ke semua tab (Home, Music, Video, Playlist, Settings),
/// ditambah MiniPlayer & CBottomNavBar yang selalu tampil di bawah.
class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  static const _screens = [
    HomeScreen(),
    MusicScreen(),
    VideoScreen(),
    PlaylistScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = ref.watch(navigationControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: activeIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          MiniPlayer(),
          CBottomNavBar(),
        ],
      ),
    );
  }
}
