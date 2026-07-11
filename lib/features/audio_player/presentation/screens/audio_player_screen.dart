import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../playlist/data/models/media_item.dart';
import '../providers/audio_provider.dart';

class AudioPlayerScreen extends ConsumerStatefulWidget {
  final MediaItem item;
  const AudioPlayerScreen({super.key, required this.item});

  @override
  ConsumerState<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends ConsumerState<AudioPlayerScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioPlayerProvider.notifier).play(widget.item);
    });
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioPlayerProvider);
    final maxSeconds = audioState.duration.inSeconds.toDouble();
    final posSeconds = audioState.position.inSeconds
        .toDouble()
        .clamp(0, maxSeconds == 0 ? 1 : maxSeconds);

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
            // Cover art dengan gradient (placeholder, karena belum ada artwork asli)
            Container(
              width: double.infinity,
              height: 320,
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(Icons.music_note_rounded, size: 96, color: Colors.white70),
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
            const SizedBox(height: 8),

            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: posSeconds.toDouble(),
                max: maxSeconds == 0 ? 1 : maxSeconds,
                activeColor: AppColors.primaryPurple,
                inactiveColor: AppColors.surfaceLight,
                onChanged: (v) {
                  ref.read(audioPlayerProvider.notifier).seek(Duration(seconds: v.toInt()));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_fmt(audioState.position), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  Text(_fmt(audioState.duration), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 28,
                  icon: const Icon(Icons.shuffle_rounded),
                  color: Colors.grey[400],
                  onPressed: () {},
                ),
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.skip_previous_rounded),
                  onPressed: () {},
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.gradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 40,
                    icon: Icon(
                      audioState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => ref.read(audioPlayerProvider.notifier).togglePlayPause(),
                  ),
                ),
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.skip_next_rounded),
                  onPressed: () {},
                ),
                IconButton(
                  iconSize: 28,
                  icon: const Icon(Icons.repeat_rounded),
                  color: Colors.grey[400],
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(icon: const Icon(Icons.volume_up_outlined), color: Colors.grey[400], onPressed: () {}),
                IconButton(icon: const Icon(Icons.equalizer_rounded), color: Colors.grey[400], onPressed: () {}),
                IconButton(icon: const Icon(Icons.queue_music_rounded), color: Colors.grey[400], onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}