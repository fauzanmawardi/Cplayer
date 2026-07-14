import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as ja;
import '../models/song_model.dart';
import '../utils/app_colors.dart';


class MusicController extends StateNotifier<List<SongModel>> {
  MusicController() : super([]);

  String _query = '';
  String get query => _query;

  final List<String> _recentlyPlayedIds = [];

  List<SongModel> get allSongs => state;

  List<SongModel> get filteredSongs {
    if (_query.trim().isEmpty) return state;
    return state
        .where((song) =>
            song.title.toLowerCase().contains(_query.toLowerCase()) ||
            song.artist.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  List<SongModel> get recentlyPlayed {
    return _recentlyPlayedIds
        .map((id) => getById(id))
        .whereType<SongModel>()
        .toList();
  }

  void search(String query) {
    _query = query;
    state = [...state];
  }

  void toggleFavorite(String songId) {
    state = [
      for (final song in state)
        if (song.id == songId)
          song.copyWith(isFavorite: !song.isFavorite)
        else
          song,
    ];
  }

  void markPlayed(String songId) {
    _recentlyPlayedIds.remove(songId);
    _recentlyPlayedIds.insert(0, songId);
    if (_recentlyPlayedIds.length > 5) {
      _recentlyPlayedIds.removeLast();
    }
    state = [...state]; // trigger rebuild untuk section "Recently Played"
  }

  SongModel? getById(String id) {
    try {
      return state.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void removeSong(String id) {
    state = state.where((s) => s.id != id).toList();
    _recentlyPlayedIds.remove(id);
  }

  /// Buka file picker device untuk memilih 1 atau banyak file audio,
  /// lalu tambahkan ke daftar lagu. Durasi lagu diambil langsung dari
  /// file asli lewat just_audio (bukan dummy).
  Future<int> importFromDevice() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return 0;

    final existingIds = state.map((s) => s.id).toSet();
    final List<SongModel> imported = [];

    for (final file in result.files) {
      final path = file.path;
      if (path == null || existingIds.contains(path)) continue;

      Duration? duration;
      final tempPlayer = ja.AudioPlayer();
      try {
        duration = await tempPlayer.setFilePath(path);
      } catch (_) {
        duration = null;
      } finally {
        await tempPlayer.dispose();
      }

      final totalSeconds = duration?.inSeconds ?? 0;
      final minutes = totalSeconds ~/ 60;
      final seconds = (totalSeconds % 60).toString().padLeft(2, '0');

      final rawName = file.name.contains('.')
          ? file.name.substring(0, file.name.lastIndexOf('.'))
          : file.name;

      imported.add(
        SongModel(
          id: path,
          title: rawName,
          artist: 'Unknown Artist',
          duration: '$minutes:$seconds',
          durationSeconds: totalSeconds,
          coverColor: AppColors
              .coverPalette[imported.length % AppColors.coverPalette.length],
          audioUrl: path,
        ),
      );
    }

    if (imported.isNotEmpty) {
      state = [...state, ...imported];
    }
    return imported.length;
  }
}

final musicControllerProvider =
    StateNotifierProvider<MusicController, List<SongModel>>((ref) {
  return MusicController();
});

final recentlyPlayedProvider = Provider<List<SongModel>>((ref) {
  ref.watch(musicControllerProvider); // trigger rebuild
  return ref.read(musicControllerProvider.notifier).recentlyPlayed;
});