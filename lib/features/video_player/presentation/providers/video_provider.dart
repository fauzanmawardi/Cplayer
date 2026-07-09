import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../playlist/data/models/media_item.dart';

class VideoPlayerNotifier extends StateNotifier<ChewieController?> {
  VideoPlayerNotifier() : super(null);

  VideoPlayerController? _videoController;

  Future<void> load(MediaItem item) async {
    await _disposeCurrent();

    final videoController = item.isLocal
        ? VideoPlayerController.file(File(item.path))
        : VideoPlayerController.network(item.path);

    await videoController.initialize();

    final chewieController = ChewieController(
      videoPlayerController: videoController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
    );

    _videoController = videoController;
    state = chewieController;
  }

  Future<void> _disposeCurrent() async {
    state?.dispose();
    await _videoController?.dispose();
    _videoController = null;
    state = null;
  }

  @override
  void dispose() {
    _disposeCurrent();
    super.dispose();
  }
}

final videoPlayerProvider =
    StateNotifierProvider<VideoPlayerNotifier, ChewieController?>(
  (ref) => VideoPlayerNotifier(),
);