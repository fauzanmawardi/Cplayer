import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../playlist/data/models/media_item.dart';
import '../providers/audio_provider.dart';

class AudioPlayerScreen extends ConsumerStatefulWidget {
  final MediaItem item;
  const AudioPlayerScreen({super.key, required this.item});

  @override
  ConsumerState<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends ConsumerState<AudioPlayerScreen> {
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
      appBar: AppBar(title: Text(widget.item.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_note, size: 96),
            const SizedBox(height: 24),
            Text(
              widget.item.title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Slider(
              value: posSeconds.toDouble(),
              max: maxSeconds == 0 ? 1 : maxSeconds,
              onChanged: (v) {
                ref.read(audioPlayerProvider.notifier).seek(Duration(seconds: v.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(audioState.position)),
                Text(_fmt(audioState.duration)),
              ],
            ),
            const SizedBox(height: 16),
            IconButton(
              iconSize: 64,
              icon: Icon(
                audioState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              ),
              onPressed: () => ref.read(audioPlayerProvider.notifier).togglePlayPause(),
            ),
          ],
        ),
      ),
    );
  }
}