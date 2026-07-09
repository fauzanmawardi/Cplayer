import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/media_item.dart';
import '../../data/repositories/playlist_repository.dart';

final playlistRepositoryProvider = Provider((ref) => PlaylistRepository());

class PlaylistNotifier extends StateNotifier<List<MediaItem>> {
  PlaylistNotifier(this._repository) : super([]);

  final PlaylistRepository _repository;

  Future<void> addLocalFiles() async {
    final newItems = await _repository.pickLocalFiles();
    if (newItems.isEmpty) return;
    state = [...state, ...newItems];
  }

  void addNetworkMedia({
    required String url,
    required String title,
    required MediaType type,
  }) {
    final item = _repository.buildNetworkItem(
      url: url,
      title: title,
      type: type,
    );
    state = [...state, item];
  }

  void remove(String id) {
    state = state.where((m) => m.id != id).toList();
  }

  void clear() => state = [];
}

final playlistProvider =
    StateNotifierProvider<PlaylistNotifier, List<MediaItem>>(
  (ref) => PlaylistNotifier(ref.read(playlistRepositoryProvider)),
);
