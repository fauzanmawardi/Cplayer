import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dummy_data.dart';
import '../models/playlist_model.dart';

/// Controller: mengelola daftar playlist.
/// Playlist detail yang sedang dibuka cukup dilempar lewat parameter
/// navigasi (Navigator), tapi provider ini tetap dipakai sebagai
/// "source of truth" daftar playlist agar konsisten di seluruh app.
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
