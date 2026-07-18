import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dummy_data.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import 'music_controller.dart';

/// Controller: menyimpan kerangka playlist (nama/ikon/warna) DAN isi lagunya
/// untuk playlist custom (Chill Vibes, Workout, Romantic, dst).
/// Catatan: playlist "Favorites" (p1) TIDAK dikelola manual di sini -
/// isinya otomatis mengikuti lagu yang ditandai favorite (lihat
/// playlistsProvider di bawah), jadi method add/remove di bawah ini
/// tidak dipakai untuk 'p1'.
class PlaylistController extends StateNotifier<List<PlaylistModel>> {
  PlaylistController() : super(DummyData.playlists);

  PlaylistModel? getById(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  bool isSongInPlaylist(String playlistId, String songId) {
    final playlist = getById(playlistId);
    if (playlist == null) return false;
    return playlist.songs.any((s) => s.id == songId);
  }

  void addSongToPlaylist(String playlistId, SongModel song) {
    state = [
      for (final p in state)
        if (p.id == playlistId && !p.songs.any((s) => s.id == song.id))
          p.copyWith(songs: [...p.songs, song])
        else
          p,
    ];
  }

  void removeSongFromPlaylist(String playlistId, String songId) {
    state = [
      for (final p in state)
        if (p.id == playlistId)
          p.copyWith(songs: p.songs.where((s) => s.id != songId).toList())
        else
          p,
    ];
  }

  /// Toggle: kalau lagu sudah ada di playlist tsb -> dihapus,
  /// kalau belum ada -> ditambahkan. Dipakai oleh checkbox di bottom sheet.
  void toggleSongInPlaylist(String playlistId, SongModel song) {
    if (isSongInPlaylist(playlistId, song.id)) {
      removeSongFromPlaylist(playlistId, song.id);
    } else {
      addSongToPlaylist(playlistId, song);
    }
  }
}

final playlistControllerProvider =
    StateNotifierProvider<PlaylistController, List<PlaylistModel>>((ref) {
  return PlaylistController();
});

/// Provider turunan: playlist "Favorites" (id 'p1') diisi OTOMATIS dari
/// lagu-lagu yang sedang ditandai favorite di MusicController.
/// Semua screen (Home, Playlist, Playlist detail) sebaiknya pakai
/// provider ini, bukan playlistControllerProvider langsung, supaya
/// jumlah & isi Favorites selalu up-to-date.
final playlistsProvider = Provider<List<PlaylistModel>>((ref) {
  final base = ref.watch(playlistControllerProvider);
  final favoriteSongs =
      ref.watch(musicControllerProvider).where((s) => s.isFavorite).toList();

  return base
      .map((playlist) => playlist.id == 'p1'
          ? playlist.copyWith(songs: favoriteSongs)
          : playlist)
      .toList();
});