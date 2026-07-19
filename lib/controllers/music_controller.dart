import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'playlist_controller.dart';
import '../models/song_model.dart';
import '../utils/app_colors.dart';

/// Opsi urutan tampilan daftar lagu di Music screen.
enum SortOption { titleAsc, durationAsc, recentlyAdded }

/// Controller: mengelola daftar lagu ASLI yang diimport dari device.
/// - search query & filter
/// - sort (nama, durasi, terbaru ditambah)
/// - toggle favorite
/// - import file audio dari penyimpanan device (pakai file_picker)
/// - catat riwayat "recently played"
class MusicController extends StateNotifier<List<SongModel>> {
  final Ref ref;
  MusicController(this.ref) : super([]);

  String _query = '';
  String get query => _query;

  SortOption _sortOption = SortOption.recentlyAdded;
  SortOption get sortOption => _sortOption;

  // Riwayat id lagu yang baru diputar (terbaru di depan), maksimal 5.
  final List<String> _recentlyPlayedIds = [];

  List<SongModel> get allSongs => state;

  List<SongModel> get filteredSongs {
    List<SongModel> result = _query.trim().isEmpty
        ? [...state]
        : state
            .where((song) =>
                song.title.toLowerCase().contains(_query.toLowerCase()) ||
                song.artist.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    switch (_sortOption) {
      case SortOption.titleAsc:
        result.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.durationAsc:
        result.sort((a, b) => a.durationSeconds.compareTo(b.durationSeconds));
        break;
      case SortOption.recentlyAdded:
        result.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
    }
    return result;
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    state = [...state]; // trigger rebuild
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

    // Bersihkan juga dari semua playlist custom (Chill Vibes, Workout, dll)
    // supaya tidak ada lagu "hantu" yang sudah dihapus tapi masih nyangkut
    // di playlist. Favorites tidak perlu dibersihkan manual karena isinya
    // otomatis mengikuti list lagu (lihat playlistsProvider).
    final playlistController = ref.read(playlistControllerProvider.notifier);
    for (final playlist in ref.read(playlistControllerProvider)) {
      if (playlist.id != 'p1') {
        playlistController.removeSongFromPlaylist(playlist.id, id);
      }
    }
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
  return MusicController(ref);
});

/// "Recently Played" untuk Home - berdasarkan riwayat lagu yang benar-benar
/// pernah diputar di sesi ini (bukan dummy statis lagi).
final recentlyPlayedProvider = Provider<List<SongModel>>((ref) {
  ref.watch(musicControllerProvider); // trigger rebuild
  return ref.read(musicControllerProvider.notifier).recentlyPlayed;
});