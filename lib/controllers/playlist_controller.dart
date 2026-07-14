import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dummy_data.dart';
import '../models/playlist_model.dart';
import 'music_controller.dart';

/// Controller: menyimpan kerangka playlist (nama/ikon/warna).
class PlaylistController extends StateNotifier<List<PlaylistModel>> {
  PlaylistController() : super(DummyData.playlists);

  PlaylistModel? getById(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
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