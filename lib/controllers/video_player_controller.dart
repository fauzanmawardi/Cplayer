import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_model.dart';

/// State untuk player video (dummy, hanya UI/logic - tanpa file video asli).
class VideoPlayerState {
  final VideoModel? currentVideo;
  final bool isPlaying;
  final int positionSeconds;
  final double speed; // 0.5x - 2.0x
  final bool subtitleOn;
  final String quality; // "1080p", "720p", dll

  const VideoPlayerState({
    this.currentVideo,
    this.isPlaying = false,
    this.positionSeconds = 0,
    this.speed = 1.0,
    this.subtitleOn = true,
    this.quality = '1080p',
  });

  VideoPlayerState copyWith({
    VideoModel? currentVideo,
    bool? isPlaying,
    int? positionSeconds,
    double? speed,
    bool? subtitleOn,
    String? quality,
  }) {
    return VideoPlayerState(
      currentVideo: currentVideo ?? this.currentVideo,
      isPlaying: isPlaying ?? this.isPlaying,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      speed: speed ?? this.speed,
      subtitleOn: subtitleOn ?? this.subtitleOn,
      quality: quality ?? this.quality,
    );
  }
}

/// Controller: mengatur video yang sedang diputar (play/pause, speed,
/// subtitle, quality). Dipakai di video_player_screen.
class VideoPlayerController extends StateNotifier<VideoPlayerState> {
  VideoPlayerController() : super(const VideoPlayerState());

  void playVideo(VideoModel video) {
    state = state.copyWith(
      currentVideo: video,
      isPlaying: true,
      positionSeconds: 0,
      quality: video.quality,
    );
  }

  void togglePlayPause() {
    if (state.currentVideo == null) return;
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void seekTo(int seconds) {
    state = state.copyWith(positionSeconds: seconds);
  }

  void setSpeed(double speed) {
    state = state.copyWith(speed: speed);
  }

  void toggleSubtitle() {
    state = state.copyWith(subtitleOn: !state.subtitleOn);
  }

  void setQuality(String quality) {
    state = state.copyWith(quality: quality);
  }
}

final videoPlayerControllerProvider =
    StateNotifierProvider<VideoPlayerController, VideoPlayerState>((ref) {
  return VideoPlayerController();
});
