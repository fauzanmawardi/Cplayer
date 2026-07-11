import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/playlist.dart';

class PlaylistsCollectionNotifier extends StateNotifier<List<Playlist>> {
  PlaylistsCollectionNotifier() : super([]);

  final _uuid = const Uuid();

  void createPlaylist(String name) {
    final playlist = Playlist(id: _uuid.v4(), name: name);
    state = [...state, playlist];
  }

  void deletePlaylist(String id) {
    state = state.where((p) => p.id != id).toList();
  }

  void addItemToPlaylist(String playlistId, String mediaItemId) {
    state = state.map((p) {
      if (p.id != playlistId) return p;
      if (p.mediaItemIds.contains(mediaItemId)) return p;
      return p.copyWith(mediaItemIds: [...p.mediaItemIds, mediaItemId]);
    }).toList();
  }

  void removeItemFromPlaylist(String playlistId, String mediaItemId) {
    state = state.map((p) {
      if (p.id != playlistId) return p;
      return p.copyWith(
        mediaItemIds: p.mediaItemIds.where((id) => id != mediaItemId).toList(),
      );
    }).toList();
  }
}

final playlistsCollectionProvider =
    StateNotifierProvider<PlaylistsCollectionNotifier, List<Playlist>>(
  (ref) => PlaylistsCollectionNotifier(),
);