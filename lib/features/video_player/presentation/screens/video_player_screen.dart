import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../playlist/data/models/media_item.dart';
import '../providers/video_provider.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final MediaItem item;
  const VideoPlayerScreen({super.key, required this.item});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(videoPlayerProvider.notifier).load(widget.item);
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chewieController = ref.watch(videoPlayerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.item.title)),
      body: Center(
        child: _loading || chewieController == null
            ? const CircularProgressIndicator()
            : AspectRatio(
                aspectRatio: chewieController.videoPlayerController.value.aspectRatio,
                child: Chewie(controller: chewieController),
              ),
      ),
    );
  }
}