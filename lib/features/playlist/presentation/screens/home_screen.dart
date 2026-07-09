import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../audio_player/presentation/screens/audio_player_screen.dart';
import '../../../video_player/presentation/screens/video_player_screen.dart';
import '../../data/models/media_item.dart';
import '../providers/playlist_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Good Morning';
    if (hour < 15) return 'Good Afternoon';
    if (hour < 19) return 'Good Evening';
    return 'Good Night';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist = ref.watch(playlistProvider);
    final audioCount = playlist.where((e) => e.type == MediaType.audio).length;
    final videoCount = playlist.where((e) => e.type == MediaType.video).length;
    final recent = playlist.reversed.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cplayer', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${_greeting()} 👋',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Let's play something awesome",
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 24),

          const Text('Quick Access', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.music_note_rounded,
                  label: 'Music',
                  subtitle: '$audioCount songs',
                  colors: const [AppColors.primaryBlue, AppColors.primaryPurple],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAccessCard(
                  icon: Icons.videocam_rounded,
                  label: 'Video',
                  subtitle: '$videoCount videos',
                  colors: const [AppColors.primaryPurple, AppColors.primaryPink],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recently Played', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(onPressed: () {}, child: const Text('View all')),
            ],
          ),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Belum ada media diputar', style: TextStyle(color: Colors.grey[500])),
            )
          else
            ...recent.map((item) => _RecentTile(
                  item: item,
                  onTap: () {
                    if (item.type == MediaType.audio) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AudioPlayerScreen(item: item)));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(item: item)));
                    }
                  },
                )),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> colors;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;

  const _RecentTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          item.type == MediaType.audio ? Icons.music_note_rounded : Icons.movie_rounded,
          color: AppColors.primaryPurple,
        ),
      ),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(item.isLocal ? 'File lokal' : 'Streaming'),
      trailing: IconButton(
        icon: const Icon(Icons.play_circle_fill, color: AppColors.primaryPurple),
        onPressed: onTap,
      ),
      onTap: onTap,
    );
  }
}