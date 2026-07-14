import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dummy_data.dart';
import '../models/song_model.dart';

/// Controller: mengelola state daftar lagu -> search query & toggle favorite.
/// Views (music_screen, playlist_detail_screen, dll) cukup "watch" provider ini.
class MusicController extends StateNotifier<List<SongModel>> {
  MusicController() : super(DummyData.songs);

  String _query = '';
  String get query => _query;

  /// Semua lagu (tanpa filter) - dipakai kalau perlu daftar penuh
  List<SongModel> get allSongs => state;

  /// Lagu setelah difilter oleh search query
  List<SongModel> get filteredSongs {
    if (_query.trim().isEmpty) return state;
    return state
        .where((song) =>
            song.title.toLowerCase().contains(_query.toLowerCase()) ||
            song.artist.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  void search(String query) {
    _query = query;
    state = [...state]; // trigger rebuild pada listener
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

  SongModel? getById(String id) {
    try {
      return state.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

final musicControllerProvider =
    StateNotifierProvider<MusicController, List<SongModel>>((ref) {
  return MusicController();
});

/// Shortcut provider untuk "Recently Played" di Home
final recentlyPlayedProvider = Provider<List<SongModel>>((ref) {
  return DummyData.recentlyPlayed;
});
