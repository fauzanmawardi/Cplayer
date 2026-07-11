import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../playlist/data/models/media_item.dart';
import '../../../playlist/presentation/providers/playlist_provider.dart';
import 'video_player_screen.dart';

class VideoTabScreen extends ConsumerWidget {
  const VideoTabScreen({super.key});

    void _showAddUrlDialog(BuildContext context, WidgetRef ref) {
    final urlController = TextEditingController();
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tambah Video dari URL'),
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
                    type: MediaType.video,
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist = ref.watch(playlistProvider);
    final videos = playlist.where((e) => e.type == MediaType.video).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addVideoUrl',
            backgroundColor: AppColors.surfaceLight,
            onPressed: () => _showAddUrlDialog(context, ref),
            child: const Icon(Icons.link),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'addVideoFile',
            backgroundColor: AppColors.primaryPurple,
            onPressed: () => ref.read(playlistProvider.notifier).addLocalFiles(),
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: videos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off_rounded, size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text('Belum ada video', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    'Tambah lewat tombol + di Home',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: videos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = videos[index];
                return _VideoCard(
                  item: item,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VideoPlayerScreen(item: item)),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;

  const _VideoCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail placeholder (belum ada generate thumbnail asli dari video)
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradient,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                ),
                if (item.isNetwork)
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.cloud_rounded, color: Colors.white70, size: 20),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.isLocal ? 'File lokal' : 'Streaming',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}