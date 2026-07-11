import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../audio_player/presentation/screens/audio_player_screen.dart';
import '../../data/models/media_item.dart';
import '../providers/playlist_provider.dart';

class MusicTabScreen extends ConsumerWidget {
  const MusicTabScreen({super.key});

  void _showAddUrlDialog(BuildContext context, WidgetRef ref) {
    final urlController = TextEditingController();
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tambah Musik dari URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.trim().isEmpty) return;
              ref.read(playlistProvider.notifier).addNetworkMedia(
                    url: urlController.text.trim(),
                    title: titleController.text.trim().isEmpty
                        ? urlController.text.trim()
                        : titleController.text.trim(),
                    type: MediaType.audio,
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Map<String, List<MediaItem>> _groupByLetter(List<MediaItem> items) {
    final sorted = [...items]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    final Map<String, List<MediaItem>> grouped = {};
    for (final item in sorted) {
      final letter = item.title.isNotEmpty ? item.title[0].toUpperCase() : '#';
      grouped.putIfAbsent(letter, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist = ref.watch(playlistProvider);
    final songs = playlist.where((e) => e.type == MediaType.audio).toList();
    final grouped = _groupByLetter(songs);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addMusicUrl',
            backgroundColor: AppColors.surfaceLight,
            onPressed: () => _showAddUrlDialog(context, ref),
            child: const Icon(Icons.link),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'addMusicFile',
            backgroundColor: AppColors.primaryPurple,
            onPressed: () => ref.read(playlistProvider.notifier).addLocalFiles(),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: songs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_off_rounded, size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text('Belum ada lagu', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    'Tambah lewat tombol + di Home',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (songs.isEmpty) return;
                          final random = songs[(songs.length * 0.37).floor() % songs.length];
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AudioPlayerScreen(item: random)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.shuffle_rounded),
                        label: const Text('Shuffle Play'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (final letter in grouped.keys) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      letter,
                      style: TextStyle(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ...grouped[letter]!.map((item) => _SongTile(item: item)),
                ],
              ],
            ),
    );
  }
}

class _SongTile extends StatelessWidget {
  final MediaItem item;
  const _SongTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.music_note_rounded, color: AppColors.primaryPurple),
      ),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(item.isLocal ? 'File lokal' : 'Streaming', style: const TextStyle(fontSize: 12)),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        color: Colors.grey[400],
        onPressed: () {},
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AudioPlayerScreen(item: item)),
        );
      },
    );
  }
}
