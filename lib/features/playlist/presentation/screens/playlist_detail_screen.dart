import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../audio_player/presentation/screens/audio_player_screen.dart';
import '../../../video_player/presentation/screens/video_player_screen.dart';
import '../../data/models/media_item.dart';
import '../../data/models/playlist.dart';
import '../providers/playlist_provider.dart';
import '../providers/playlists_collection_provider.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final String playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  void _showAddItemsDialog(BuildContext context, WidgetRef ref, Playlist playlist) {
    final library = ref.read(playlistProvider);
    final available = library.where((m) => !playlist.mediaItemIds.contains(m.id)).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tambah ke Playlist'),
        content: SizedBox(
          width: double.maxFinite,
          child: available.isEmpty
              ? const Text('Semua media sudah ada di playlist ini, atau koleksi kamu masih kosong.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: available.length,
                  itemBuilder: (context, index) {
                    final item = available[index];
                    return ListTile(
                      leading: Icon(
                        item.type == MediaType.audio ? Icons.music_note_rounded : Icons.movie_rounded,
                        color: AppColors.primaryPurple,
                      ),
                      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () {
                        ref.read(playlistsCollectionProvider.notifier)
                            .addItemToPlaylist(playlist.id, item.id);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsCollectionProvider);
    final playlist = playlists.firstWhere((p) => p.id == playlistId);
    final library = ref.watch(playlistProvider);
    final items = playlist.mediaItemIds
        .map((id) => library.where((m) => m.id == id))
        .whereType<MediaItem>()
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(playlist.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  height: 140,
                  width: 140,
                  decoration: const BoxDecoration(
                    gradient: AppColors.gradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.queue_music_rounded, size: 56, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(playlist.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${items.length} item', style: TextStyle(color: Colors.grey[400])),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: items.isEmpty
                            ? null
                            : () {
                                final first = items.first;
                                if (first.type == MediaType.audio) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => AudioPlayerScreen(item: first)));
                                } else {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(item: first)));
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play All'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddItemsDialog(context, ref, playlist),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text('Belum ada item di playlist ini', style: TextStyle(color: Colors.grey[500])),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.type == MediaType.audio ? Icons.music_note_rounded : Icons.movie_rounded,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: Colors.grey[400],
                          onPressed: () => ref
                              .read(playlistsCollectionProvider.notifier)
                              .removeItemFromPlaylist(playlist.id, item.id),
                        ),
                        onTap: () {
                          if (item.type == MediaType.audio) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AudioPlayerScreen(item: item)));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(item: item)));
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}