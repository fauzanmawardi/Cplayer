import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../playlist/data/models/media_item.dart';

class AudioPlayerState {
  final MediaItem? current;
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  const AudioPlayerState({
    this.current,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  AudioPlayerState copyWith({
    MediaItem? current,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    return AudioPlayerState(
      current: current ?? this.current,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  AudioPlayerNotifier() : super(const AudioPlayerState()) {
    _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });
    _player.durationStream.listen((dur) {
      state = state.copyWith(duration: dur ?? Duration.zero);
    });
    _player.playerStateStream.listen((ps) {
      state = state.copyWith(isPlaying: ps.playing);
    });
  }

  final AudioPlayer _player = AudioPlayer();

  Future<void> play(MediaItem item) async {
    if (item.isLocal) {
      await _player.setFilePath(item.path);
    } else {
      await _player.setUrl(item.path);
    }
    state = state.copyWith(current: item);
    await _player.play();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> stop() => _player.stop();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>(
  (ref) => AudioPlayerNotifier(),
);