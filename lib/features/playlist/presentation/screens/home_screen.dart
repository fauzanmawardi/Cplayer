import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_player/presentation/screens/audio_player_screen.dart';
import '../../../video_player/presentation/screens/video_player_screen.dart';
import '../../data/models/media_item.dart';
import '../providers/playlist_provider.dart';
import '../widgets/media_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddUrlDialog(BuildContext context, WidgetRef ref) {
    final urlController = TextEditingController();
    final titleController = TextEditingController();
    MediaType selectedType =
        _tabController.index == 0 ? MediaType.audio : MediaType.video;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tambah dari URL'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<MediaType>(
                      title: const Text('Audio'),
                      value: MediaType.audio,
                      groupValue: selectedType,
                      onChanged: (v) => setState(() => selectedType = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<MediaType>(
                      title: const Text('Video'),
                      value: MediaType.video,
                      groupValue: selectedType,
                      onChanged: (v) => setState(() => selectedType = v!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (urlController.text.trim().isEmpty) return;
                ref.read(playlistProvider.notifier).addNetworkMedia(
                      url: urlController.text.trim(),
                      title: titleController.text.trim().isEmpty
                          ? urlController.text.trim()
                          : titleController.text.trim(),
                      type: selectedType,
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaList(List<MediaItem> items, MediaType type) {
    final filtered = items.where((e) => e.type == type).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == MediaType.audio ? Icons.music_off : Icons.videocam_off,
              size: 64,
              color: Colors.grey[350],
            ),
            const SizedBox(height: 16),
            Text(
              type == MediaType.audio ? 'Belum ada audio' : 'Belum ada video',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return MediaCard(
          item: item,
          onTap: () {
            if (item.type == MediaType.audio) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AudioPlayerScreen(item: item)),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VideoPlayerScreen(item: item)),
              );
            }
          },
          onDelete: () => ref.read(playlistProvider.notifier).remove(item.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final playlist = ref.watch(playlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cplayer', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.music_note), text: 'Audio'),
            Tab(icon: Icon(Icons.movie), text: 'Video'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMediaList(playlist, MediaType.audio),
          _buildMediaList(playlist, MediaType.video),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addUrl',
            onPressed: () => _showAddUrlDialog(context, ref),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: const Icon(Icons.link),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'addFile',
            onPressed: () => ref.read(playlistProvider.notifier).addLocalFiles(),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}