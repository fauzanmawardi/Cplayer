import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dummy_data.dart';
import '../models/song_model.dart';

/// State untuk player audio (dummy, tidak memutar file asli - hanya UI/logic).
class PlayerState {
  final SongModel? currentSong;
  final bool isPlaying;
  final int positionSeconds; // posisi berjalan (detik)
  final bool isShuffle;
  final bool isRepeat;

  const PlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.positionSeconds = 0,
    this.isShuffle = false,
    this.isRepeat = false,
  });

  PlayerState copyWith({
    SongModel? currentSong,
    bool? isPlaying,
    int? positionSeconds,
    bool? isShuffle,
    bool? isRepeat,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      isShuffle: isShuffle ?? this.isShuffle,
      isRepeat: isRepeat ?? this.isRepeat,
    );
  }
}

/// Controller: mengatur lagu yang sedang diputar, play/pause, next/prev,
/// shuffle & repeat. Berlaku untuk mini player & now playing screen.
class PlayerController extends StateNotifier<PlayerState> {
  PlayerController() : super(const PlayerState());

  List<SongModel> get _queue => DummyData.songs;

  void playSong(SongModel song) {
    state = state.copyWith(
      currentSong: song,
      isPlaying: true,
      positionSeconds: 0,
    );
  }

  void togglePlayPause() {
    if (state.currentSong == null) return;
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void seekTo(int seconds) {
    state = state.copyWith(positionSeconds: seconds);
  }

  void toggleShuffle() {
    state = state.copyWith(isShuffle: !state.isShuffle);
  }

  void toggleRepeat() {
    state = state.copyWith(isRepeat: !state.isRepeat);
  }

  void playNext() {
    final song = state.currentSong;
    if (song == null) return;
    final idx = _queue.indexWhere((s) => s.id == song.id);
    final nextIdx = (idx + 1) % _queue.length;
    playSong(_queue[nextIdx]);
  }

  void playPrevious() {
    final song = state.currentSong;
    if (song == null) return;
    final idx = _queue.indexWhere((s) => s.id == song.id);
    final prevIdx = (idx - 1 + _queue.length) % _queue.length;
    playSong(_queue[prevIdx]);
  }
}

final playerControllerProvider =
    StateNotifierProvider<PlayerController, PlayerState>((ref) {
  return PlayerController();
});
