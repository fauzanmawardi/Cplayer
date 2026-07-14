import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/music_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/player_controller.dart';
import '../../controllers/playlist_controller.dart';
import '../../controllers/video_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../widgets/playlist_card.dart';
import '../widgets/quick_access_card.dart';
import '../widgets/section_header.dart';
import '../widgets/song_tile.dart';
import 'playlist_detail_screen.dart';

/// View: halaman Home (Quick Access, Recently Played, Playlists).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSongs = ref.watch(recentlyPlayedProvider);
    final playlists = ref.watch(playlistsProvider);
    final totalSongs = ref.watch(musicControllerProvider).length;
    final totalVideos = ref.watch(videoControllerProvider).length;
    final currentSong = ref.watch(playerControllerProvider).currentSong;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        children: [
          // ---------- Top bar: logo + search ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: Text('Cplayer', style: AppTextStyles.logo.copyWith(fontSize: 22)),
              ),
              const Icon(Icons.search, color: AppColors.textPrimary),
            ],
          ),
          const SizedBox(height: 20),

          // ---------- Greeting ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good Evening 👋', style: AppTextStyles.heading),
                    const SizedBox(height: 4),
                    Text("Let's play something awesome",
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---------- Quick Access ----------
          SectionHeader(
            title: 'Quick Access',
            onViewAll: () {},
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              QuickAccessCard(
                title: 'Music',
                subtitle: '$totalSongs songs',
                icon: Icons.music_note_rounded,
                gradient: AppColors.musicCardGradient,
                onTap: () =>
                    ref.read(navigationControllerProvider.notifier).state = 1,
              ),
              const SizedBox(width: 12),
              QuickAccessCard(
                title: 'Video',
                subtitle: '$totalVideos videos',
                icon: Icons.videocam_rounded,
                gradient: AppColors.videoCardGradient,
                onTap: () =>
                    ref.read(navigationControllerProvider.notifier).state = 2,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---------- Recently Played ----------
          SectionHeader(
            title: 'Recently Played',
            onViewAll: () =>
                ref.read(navigationControllerProvider.notifier).state = 1,
          ),
          const SizedBox(height: 8),
          if (recentSongs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Belum ada lagu yang diputar. Import lagu di tab Music dulu.',
                style: AppTextStyles.caption,
              ),
            )
          else
            ...recentSongs.map(
              (song) => SongTile(
                song: song,
                isPlaying: currentSong?.id == song.id,
                onTap: () => ref
                    .read(playerControllerProvider.notifier)
                    .playSong(song),
              ),
            ),
          const SizedBox(height: 16),

          // ---------- Playlists ----------
          SectionHeader(title: 'Playlists', onViewAll: () {}),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: playlists.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final playlist = playlists[i];
                return PlaylistCard(
                  playlist: playlist,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlaylistDetailScreen(playlist: playlist),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}