import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/video_controller.dart';
import '../../controllers/video_player_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

/// View: halaman Now Playing untuk video (player, speed, subtitle, quality).
class VideoPlayerScreen extends ConsumerWidget {
  const VideoPlayerScreen({super.key});

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(videoPlayerControllerProvider);
    final video = playerState.currentVideo;

    if (video == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Belum ada video yang diputar',
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
              const SizedBox(height: 16),

              // ---------- Area Video ----------
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            video.thumbColor.withOpacity(0.9),
                            AppColors.background,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => ref
                          .read(videoPlayerControllerProvider.notifier)
                          .togglePlayPause(),
                      icon: Icon(
                        playerState.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        color: Colors.white.withOpacity(0.9),
                        size: 64,
                      ),
                    ),
                    // Progress overlay di bawah area video
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: Row(
                        children: [
                          Text(_formatTime(playerState.positionSeconds),
                              style: AppTextStyles.caption
                                  .copyWith(color: Colors.white)),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 5),
                              ),
                              child: Slider(
                                value: playerState.positionSeconds
                                    .clamp(0, video.durationSeconds)
                                    .toDouble(),
                                max: video.durationSeconds.toDouble(),
                                activeColor: AppColors.favorite,
                                inactiveColor: Colors.white24,
                                onChanged: (value) => ref
                                    .read(videoPlayerControllerProvider
                                        .notifier)
                                    .seekTo(value.toInt()),
                              ),
                            ),
                          ),
                          Text(video.duration,
                              style: AppTextStyles.caption
                                  .copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ---------- Title & favorite ----------
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(video.title, style: AppTextStyles.heading),
                        const SizedBox(height: 4),
                        Text(video.quality, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(videoControllerProvider.notifier)
                        .toggleFavorite(video.id),
                    icon: Icon(
                      video.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.favorite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ---------- Kontrol utama ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.skip_previous_rounded,
                        color: AppColors.textPrimary, size: 30),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => ref
                          .read(videoPlayerControllerProvider.notifier)
                          .togglePlayPause(),
                      icon: Icon(
                        playerState.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.skip_next_rounded,
                        color: AppColors.textPrimary, size: 30),
                  ),
                  const Icon(Icons.fullscreen, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 14),

              // ---------- Speed / Subtitle / Quality ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _InfoButton(
                    label: '${playerState.speed}x',
                    caption: 'Speed',
                    onTap: () {
                      const speeds = [0.5, 1.0, 1.5, 2.0];
                      final nextIndex =
                          (speeds.indexOf(playerState.speed) + 1) %
                              speeds.length;
                      ref
                          .read(videoPlayerControllerProvider.notifier)
                          .setSpeed(speeds[nextIndex]);
                    },
                  ),
                  _InfoButton(
                    label: 'CC',
                    caption: 'Subtitle',
                    isActive: playerState.subtitleOn,
                    onTap: () => ref
                        .read(videoPlayerControllerProvider.notifier)
                        .toggleSubtitle(),
                  ),
                  _InfoButton(
                    label: playerState.quality,
                    caption: 'Quality',
                    onTap: () {
                      const qualities = ['1080p', '720p', '480p'];
                      final nextIndex =
                          (qualities.indexOf(playerState.quality) + 1) %
                              qualities.length;
                      ref
                          .read(videoPlayerControllerProvider.notifier)
                          .setQuality(qualities[nextIndex]);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoButton extends StatelessWidget {
  final String label;
  final String caption;
  final bool isActive;
  final VoidCallback onTap;

  const _InfoButton({
    required this.label,
    required this.caption,
    required this.onTap,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(caption, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
