import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
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
  bool _isFavorite = false;

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
      appBar: AppBar(
        title: const Text('Now Playing'),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _loading || chewieController == null
                    ? Container(
                        color: AppColors.surface,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : Chewie(controller: chewieController),
              ),
            ),
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.isLocal ? 'File lokal' : 'Streaming',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? AppColors.primaryPink : Colors.grey,
                  ),
                  onPressed: () => setState(() => _isFavorite = !_isFavorite),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(iconSize: 28, icon: const Icon(Icons.lock_outline_rounded), color: Colors.grey[400], onPressed: () {}),
                IconButton(iconSize: 36, icon: const Icon(Icons.skip_previous_rounded), onPressed: () {}),
                Container(
                  decoration: const BoxDecoration(gradient: AppColors.gradient, shape: BoxShape.circle),
                  child: IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                    onPressed: () {
                      chewieController?.videoPlayerController.value.isPlaying ?? false
                          ? chewieController?.pause()
                          : chewieController?.play();
                    },
                  ),
                ),
                IconButton(iconSize: 36, icon: const Icon(Icons.skip_next_rounded), onPressed: () {}),
                IconButton(iconSize: 28, icon: const Icon(Icons.fullscreen_rounded), color: Colors.grey[400], onPressed: () {
                  chewieController?.enterFullScreen();
                }),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BottomInfoChip(label: '1.0x', icon: Icons.speed_rounded),
                _BottomInfoChip(label: 'Subtitle', icon: Icons.subtitles_outlined),
                _BottomInfoChip(label: '1080p', icon: Icons.hd_rounded),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _BottomInfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _BottomInfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }
}