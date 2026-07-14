import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'music_controller.dart';
import '../models/song_model.dart';

/// State untuk player audio.
/// Catatan: package just_audio juga punya class bernama "PlayerState",
/// makanya import just_audio diberi alias `ja` supaya tidak bentrok nama
/// dengan class PlayerState milik kita sendiri di bawah ini.
class PlayerState {
  final SongModel? currentSong;
  final bool isPlaying;
  final int positionSeconds; // posisi berjalan (detik) - dari stream asli
  final bool isShuffle;
  final bool isRepeat;
  final bool isBuffering;

  const PlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.positionSeconds = 0,
    this.isShuffle = false,
    this.isRepeat = false,
    this.isBuffering = false,
  });

  PlayerState copyWith({
    SongModel? currentSong,
    bool? isPlaying,
    int? positionSeconds,
    bool? isShuffle,
    bool? isRepeat,
    bool? isBuffering,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      isShuffle: isShuffle ?? this.isShuffle,
      isRepeat: isRepeat ?? this.isRepeat,
      isBuffering: isBuffering ?? this.isBuffering,
    );
  }
}

/// Controller: player audio ASLI menggunakan package just_audio.
/// [song.audioUrl] sekarang berisi PATH FILE ASLI di device (hasil
/// import lewat MusicController.importFromDevice()), jadi diputar
/// dengan setFilePath(). Kalau suatu saat ada sumber dari internet
/// (URL http/https), otomatis dipakai setUrl() sebagai gantinya.
class PlayerController extends StateNotifier<PlayerState> {
  final Ref ref;
  final ja.AudioPlayer _audioPlayer = ja.AudioPlayer();
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<ja.PlayerState>? _justAudioStateSub;

  PlayerController(this.ref) : super(const PlayerState()) {
    _positionSub = _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(positionSeconds: position.inSeconds);
    });

    _justAudioStateSub = _audioPlayer.playerStateStream.listen((audioState) {
      state = state.copyWith(
        isBuffering:
            audioState.processingState == ja.ProcessingState.buffering ||
                audioState.processingState == ja.ProcessingState.loading,
      );

      if (audioState.processingState == ja.ProcessingState.completed) {
        if (state.isRepeat) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        } else {
          playNext();
        }
      }
    });
  }

  List<SongModel> get _queue => ref.read(musicControllerProvider);

  /// Memutar lagu baru: load file/URL audio-nya lalu play.
  Future<void> playSong(SongModel song) async {
    state = state.copyWith(
      currentSong: song,
      isPlaying: true,
      positionSeconds: 0,
    );
    try {
      final isRemote = song.audioUrl.startsWith('http://') ||
          song.audioUrl.startsWith('https://');
      if (isRemote) {
        await _audioPlayer.setUrl(song.audioUrl);
      } else {
        await _audioPlayer.setFilePath(song.audioUrl);
      }
      await _audioPlayer.play();
      ref.read(musicControllerProvider.notifier).markPlayed(song.id);
    } catch (e) {
      // Kalau gagal load (file terhapus/dipindah, dsb), tetap tampilkan
      // UI tapi status berhenti main.
      state = state.copyWith(isPlaying: false);
    }
  }

  Future<void> togglePlayPause() async {
    if (state.currentSong == null) return;
    if (state.isPlaying) {
      await _audioPlayer.pause();
      state = state.copyWith(isPlaying: false);
    } else {
      await _audioPlayer.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  Future<void> seekTo(int seconds) async {
    await _audioPlayer.seek(Duration(seconds: seconds));
    state = state.copyWith(positionSeconds: seconds);
  }

  void toggleShuffle() {
    state = state.copyWith(isShuffle: !state.isShuffle);
  }

  void toggleRepeat() {
    state = state.copyWith(isRepeat: !state.isRepeat);
  }

  Future<void> playNext() async {
    final song = state.currentSong;
    final queue = _queue;
    if (song == null || queue.isEmpty) return;

    if (state.isShuffle) {
      final random = [...queue]..shuffle();
      await playSong(random.first);
      return;
    }

    final idx = queue.indexWhere((s) => s.id == song.id);
    if (idx == -1) return;
    final nextIdx = (idx + 1) % queue.length;
    await playSong(queue[nextIdx]);
  }

  Future<void> playPrevious() async {
    final song = state.currentSong;
    final queue = _queue;
    if (song == null || queue.isEmpty) return;
    final idx = queue.indexWhere((s) => s.id == song.id);
    if (idx == -1) return;
    final prevIdx = (idx - 1 + queue.length) % queue.length;
    await playSong(queue[prevIdx]);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _justAudioStateSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

final playerControllerProvider =
    StateNotifierProvider<PlayerController, PlayerState>((ref) {
  return PlayerController(ref);
});