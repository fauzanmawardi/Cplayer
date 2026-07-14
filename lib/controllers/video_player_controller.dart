import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart' as vp;
import 'video_controller.dart';
import '../models/video_model.dart';

/// State untuk player video.
class VideoPlayerState {
  final VideoModel? currentVideo;
  final bool isPlaying;
  final int positionSeconds;
  final double speed; // 0.5x - 2.0x
  final bool subtitleOn; // catatan: video_player tidak render subtitle
  final String quality; // hanya label - 1 file lokal = 1 kualitas asli
  final bool isInitialized;
  final vp.VideoPlayerController? controller; // dipakai widget VideoPlayer()

  const VideoPlayerState({
    this.currentVideo,
    this.isPlaying = false,
    this.positionSeconds = 0,
    this.speed = 1.0,
    this.subtitleOn = true,
    this.quality = 'Device',
    this.isInitialized = false,
    this.controller,
  });

  VideoPlayerState copyWith({
    VideoModel? currentVideo,
    bool? isPlaying,
    int? positionSeconds,
    double? speed,
    bool? subtitleOn,
    String? quality,
    bool? isInitialized,
    vp.VideoPlayerController? controller,
  }) {
    return VideoPlayerState(
      currentVideo: currentVideo ?? this.currentVideo,
      isPlaying: isPlaying ?? this.isPlaying,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      speed: speed ?? this.speed,
      subtitleOn: subtitleOn ?? this.subtitleOn,
      quality: quality ?? this.quality,
      isInitialized: isInitialized ?? this.isInitialized,
      controller: controller ?? this.controller,
    );
  }
}

/// Controller: player video ASLI menggunakan package video_player.
/// [video.sourcePath] adalah path file video di device.
class VideoPlayerController extends StateNotifier<VideoPlayerState> {
  final Ref ref;
  VideoPlayerController(this.ref) : super(const VideoPlayerState());

  vp.VideoPlayerController? _controller;

  List<VideoModel> get _queue => ref.read(videoControllerProvider);

  void _onTick() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    state = state.copyWith(
      positionSeconds: c.value.position.inSeconds,
      isPlaying: c.value.isPlaying,
    );
  }

  Future<void> playVideo(VideoModel video) async {
    // Buang controller lama kalau ada
    _controller?.removeListener(_onTick);
    await _controller?.dispose();

    state = state.copyWith(
      currentVideo: video,
      isPlaying: false,
      positionSeconds: 0,
      quality: video.quality,
      isInitialized: false,
      controller: null,
    );

    final newController = vp.VideoPlayerController.file(File(video.sourcePath));
    _controller = newController;

    try {
      await newController.initialize();
      await newController.setPlaybackSpeed(state.speed);
      newController.addListener(_onTick);
      await newController.play();
      state = state.copyWith(
        isPlaying: true,
        isInitialized: true,
        controller: newController,
      );
    } catch (e) {
      state = state.copyWith(isPlaying: false, isInitialized: false);
    }
  }

  Future<void> togglePlayPause() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (state.isPlaying) {
      await c.pause();
    } else {
      await c.play();
    }
  }

  Future<void> seekTo(int seconds) async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    await c.seekTo(Duration(seconds: seconds));
    state = state.copyWith(positionSeconds: seconds);
  }

  Future<void> setSpeed(double speed) async {
    state = state.copyWith(speed: speed);
    final c = _controller;
    if (c != null && c.value.isInitialized) {
      await c.setPlaybackSpeed(speed);
    }
  }

  void toggleSubtitle() {
    state = state.copyWith(subtitleOn: !state.subtitleOn);
  }

  void setQuality(String quality) {
    state = state.copyWith(quality: quality);
  }

  Future<void> playNext() async {
    final video = state.currentVideo;
    final queue = _queue;
    if (video == null || queue.isEmpty) return;
    final idx = queue.indexWhere((v) => v.id == video.id);
    if (idx == -1) return;
    final nextIdx = (idx + 1) % queue.length;
    await playVideo(queue[nextIdx]);
  }

  Future<void> playPrevious() async {
    final video = state.currentVideo;
    final queue = _queue;
    if (video == null || queue.isEmpty) return;
    final idx = queue.indexWhere((v) => v.id == video.id);
    if (idx == -1) return;
    final prevIdx = (idx - 1 + queue.length) % queue.length;
    await playVideo(queue[prevIdx]);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }
}

final videoPlayerControllerProvider =
    StateNotifierProvider<VideoPlayerController, VideoPlayerState>((ref) {
  return VideoPlayerController(ref);
});