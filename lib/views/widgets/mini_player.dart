import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/player_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../screens/now_playing_screen.dart';

/// Widget: mini player bar, muncul di atas bottom nav bar ketika
/// ada lagu yang sedang diputar. Membaca [playerControllerProvider].
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);
    final song = playerState.currentSong;

    if (song == null) return const SizedBox.shrink();

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
        );
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: song.coverColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.music_note, color: song.coverColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(song.title,
                      style: AppTextStyles.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(song.artist, style: AppTextStyles.caption),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                playerState.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: () =>
                  ref.read(playerControllerProvider.notifier).togglePlayPause(),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next_rounded,
                  color: AppColors.textSecondary),
              onPressed: () =>
                  ref.read(playerControllerProvider.notifier).playNext(),
            ),
          ],
        ),
      ),
    );
  }
}
