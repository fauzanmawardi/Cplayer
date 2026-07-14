import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/music_controller.dart';
import '../../controllers/player_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

/// View: halaman Now Playing untuk audio (cover besar, seekbar, kontrol).
class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(1, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);
    final song = playerState.currentSong;

    if (song == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Belum ada lagu yang diputar',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            children: [
              // ---------- Header ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textPrimary, size: 28),
                  ),
                  Text('Now Playing', style: AppTextStyles.subheading),
                  const Icon(Icons.more_vert, color: AppColors.textPrimary),
                ],
              ),
              const Spacer(),

              // ---------- Cover Art ----------
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      song.coverColor.withOpacity(0.9),
                      AppColors.background,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(Icons.music_note,
                    color: Colors.white.withOpacity(0.85), size: 90),
              ),
              const Spacer(),

              // ---------- Title, artist, favorite ----------
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song.title, style: AppTextStyles.heading),
                        const SizedBox(height: 4),
                        Text(song.artist, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(musicControllerProvider.notifier)
                        .toggleFavorite(song.id),
                    icon: Icon(
                      song.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.favorite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ---------- Seekbar ----------
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: playerState.positionSeconds
                      .clamp(0, song.durationSeconds)
                      .toDouble(),
                  max: song.durationSeconds.toDouble(),
                  min: 0,
                  activeColor: AppColors.favorite,
                  inactiveColor: AppColors.divider,
                  onChanged: (value) => ref
                      .read(playerControllerProvider.notifier)
                      .seekTo(value.toInt()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatTime(playerState.positionSeconds),
                        style: AppTextStyles.caption),
                    Text(song.duration, style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ---------- Kontrol ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => ref
                        .read(playerControllerProvider.notifier)
                        .toggleShuffle(),
                    icon: Icon(
                      Icons.shuffle,
                      color: playerState.isShuffle
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(playerControllerProvider.notifier)
                        .playPrevious(),
                    icon: const Icon(Icons.skip_previous_rounded,
                        color: AppColors.textPrimary, size: 32),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => ref
                          .read(playerControllerProvider.notifier)
                          .togglePlayPause(),
                      icon: Icon(
                        playerState.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(playerControllerProvider.notifier)
                        .playNext(),
                    icon: const Icon(Icons.skip_next_rounded,
                        color: AppColors.textPrimary, size: 32),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(playerControllerProvider.notifier)
                        .toggleRepeat(),
                    icon: Icon(
                      Icons.repeat_rounded,
                      color: playerState.isRepeat
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ---------- Bar bawah (volume, equalizer, queue) ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.volume_up_outlined, color: AppColors.textSecondary),
                  Icon(Icons.equalizer_rounded, color: AppColors.textSecondary),
                  Icon(Icons.queue_music_rounded, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
