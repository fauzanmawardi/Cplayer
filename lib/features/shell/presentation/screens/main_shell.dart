import 'package:flutter/material.dart';

import '../../../playlist/presentation/screens/home_screen.dart';
import '../../../playlist/presentation/screens/music_tab_screen.dart';
import '../../../playlist/presentation/screens/playlist_tab_screen.dart';
import '../../../settings/presentation/screens/more_tab_screen.dart';
import '../../../video_player/presentation/screens/video_tab_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goToTab(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateToTab: _goToTab),
      const MusicTabScreen(),
      const VideoTabScreen(),
      const PlaylistTabScreen(),
      const MoreTabScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _goToTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note_rounded), label: 'Music'),
          BottomNavigationBarItem(icon: Icon(Icons.videocam_rounded), label: 'Video'),
          BottomNavigationBarItem(icon: Icon(Icons.queue_music_rounded), label: 'Playlist'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz_rounded), label: 'More'),
        ],
      ),
    );
  }
}