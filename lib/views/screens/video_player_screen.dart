import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart' as vp;
import '../../controllers/video_controller.dart';
import '../../controllers/video_player_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

/// View: halaman Now Playing untuk video (player, speed, subtitle, quality).
class VideoPlayerScreen extends ConsumerStatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  bool _isFullScreen = false;

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _toggleFullScreen() async {
    setState(() => _isFullScreen = !_isFullScreen);
    if (_isFullScreen) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    // Pastikan orientasi & system UI kembali normal saat keluar halaman ini,
    // supaya tidak "kebawa" landscape ke halaman lain.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    if (_isFullScreen) {
      return _buildFullScreenView(video, playerState);
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
                child: SizedBox(
                  width: double.infinity,
                  child: _VideoSurface(
                    video: video,
                    playerState: playerState,
                    onTogglePlayPause: () => ref
                        .read(videoPlayerControllerProvider.notifier)
                        .togglePlayPause(),
                    onSeek: (value) => ref
                        .read(videoPlayerControllerProvider.notifier)
                        .seekTo(value),
                    formatTime: _formatTime,
                  ),
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
                    onPressed: () => ref
                        .read(videoPlayerControllerProvider.notifier)
                        .playPrevious(),
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
                    onPressed: () => ref
                        .read(videoPlayerControllerProvider.notifier)
                        .playNext(),
                    icon: const Icon(Icons.skip_next_rounded,
                        color: AppColors.textPrimary, size: 30),
                  ),
                  GestureDetector(
                    onTap: _toggleFullScreen,
                    child: const Icon(Icons.fullscreen,
                        color: AppColors.textSecondary),
                  ),
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

  /// Tampilan khusus fullscreen: video mengisi SELURUH layar (landscape),
  /// tanpa header/title/speed-row - cuma overlay kontrol minimal.
  Widget _buildFullScreenView(video, playerState) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: _VideoSurface(
                video: video,
                playerState: playerState,
                onTogglePlayPause: () => ref
                    .read(videoPlayerControllerProvider.notifier)
                    .togglePlayPause(),
                onSeek: (value) => ref
                    .read(videoPlayerControllerProvider.notifier)
                    .seekTo(value),
                formatTime: _formatTime,
                borderRadius: 0,
              ),
            ),
            // Tombol keluar fullscreen
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: GestureDetector(
                  onTap: _toggleFullScreen,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.fullscreen_exit,
                        color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
            // Kontrol prev/play/next di tengah bawah
            Positioned(
              bottom: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => ref
                        .read(videoPlayerControllerProvider.notifier)
                        .playPrevious(),
                    icon: const Icon(Icons.skip_previous_rounded,
                        color: Colors.white, size: 34),
                  ),
                  const SizedBox(width: 12),
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
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => ref
                        .read(videoPlayerControllerProvider.notifier)
                        .playNext(),
                    icon: const Icon(Icons.skip_next_rounded,
                        color: Colors.white, size: 34),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget reusable: area video (dipakai di mode normal & fullscreen)
/// supaya tidak duplikasi kode Stack + FittedBox + progress overlay.
class _VideoSurface extends StatelessWidget {
  final dynamic video;
  final dynamic playerState;
  final VoidCallback onTogglePlayPause;
  final ValueChanged<int> onSeek;
  final String Function(int) formatTime;
  final double borderRadius;

  const _VideoSurface({
    required this.video,
    required this.playerState,
    required this.onTogglePlayPause,
    required this.onSeek,
    required this.formatTime,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: (playerState.isInitialized && playerState.controller != null)
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: playerState.controller!.value.size.width,
                      height: playerState.controller!.value.size.height,
                      child: vp.VideoPlayer(playerState.controller!),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          video.thumbColor.withOpacity(0.9),
                          AppColors.background,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
          ),
        ),
        IconButton(
          onPressed: onTogglePlayPause,
          icon: Icon(
            playerState.isPlaying
                ? Icons.pause_circle_filled
                : Icons.play_circle_fill,
            color: Colors.white.withOpacity(0.9),
            size: 64,
          ),
        ),
        Positioned(
          left: 8,
          right: 8,
          bottom: 8,
          child: Row(
            children: [
              Text(formatTime(playerState.positionSeconds),
                  style: AppTextStyles.caption.copyWith(color: Colors.white)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 5),
                  ),
                  child: Slider(
                    value: (playerState.positionSeconds as int)
                        .clamp(0, video.durationSeconds)
                        .toDouble(),
                    max: video.durationSeconds.toDouble(),
                    activeColor: AppColors.favorite,
                    inactiveColor: Colors.white24,
                    onChanged: (value) => onSeek(value.toInt()),
                  ),
                ),
              ),
              Text(video.duration,
                  style: AppTextStyles.caption.copyWith(color: Colors.white)),
            ],
          ),
        ),
      ],
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