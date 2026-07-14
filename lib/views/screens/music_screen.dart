import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/music_controller.dart';
import '../../controllers/player_controller.dart';
import '../../models/song_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../widgets/song_tile.dart';

/// View: halaman daftar lagu (Songs/Albums/Artists/Folders).
/// Hanya tab "Songs" yang fungsional untuk saat ini (sesuai scope UI+dummy).
class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({super.key});

  @override
  ConsumerState<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen> {
  final List<String> _tabs = const ['Songs', 'Albums', 'Artists', 'Folders'];
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(musicControllerProvider);
    final currentSong = ref.watch(playerControllerProvider).currentSong;

    // Kelompokkan lagu berdasarkan huruf awal judul (mis. "A", "B", ...)
    final sorted = [...songs]..sort((a, b) => a.title.compareTo(b.title));
    final Map<String, List<SongModel>> grouped = {};
    for (final song in sorted) {
      final letter = song.title.substring(0, 1).toUpperCase();
      grouped.putIfAbsent(letter, () => []).add(song);
    }

    return SafeArea(
      child: Column(
        children: [
          // ---------- Header ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
                Text('Music', style: AppTextStyles.heading),
                const Icon(Icons.search, color: AppColors.textPrimary),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---------- Tabs ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final isActive = i == _activeTab;
                return Padding(
                  padding: const EdgeInsets.only(right: 22),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = i),
                    child: Column(
                      children: [
                        Text(
                          _tabs[i],
                          style: AppTextStyles.body.copyWith(
                            color: isActive
                                ? AppColors.favorite
                                : AppColors.textSecondary,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (isActive)
                          Container(
                            height: 2,
                            width: 24,
                            color: AppColors.favorite,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(color: AppColors.divider, height: 20),

          // ---------- Konten ----------
          Expanded(
            child: _activeTab == 0
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    children: [
                      // Shuffle Play row
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.surfaceLight,
                          child: Icon(Icons.shuffle, color: AppColors.accent),
                        ),
                        title: Text('Shuffle Play', style: AppTextStyles.body),
                        subtitle: Text('${songs.length} songs',
                            style: AppTextStyles.caption),
                        onTap: () {
                          if (songs.isNotEmpty) {
                            final random = songs..shuffle();
                            ref
                                .read(playerControllerProvider.notifier)
                                .playSong(random.first);
                          }
                        },
                      ),
                      const SizedBox(height: 4),

                      // List lagu dikelompokkan per huruf
                      for (final entry in grouped.entries) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(entry.key,
                              style: AppTextStyles.subheading
                                  .copyWith(color: AppColors.textMuted)),
                        ),
                        for (final song in entry.value)
                          SongTile(
                            song: song,
                            isPlaying: currentSong?.id == song.id,
                            onTap: () => ref
                                .read(playerControllerProvider.notifier)
                                .playSong(song),
                            onMoreTap: () => ref
                                .read(musicControllerProvider.notifier)
                                .toggleFavorite(song.id),
                          ),
                      ],
                      const SizedBox(height: 80),
                    ],
                  )
                : Center(
                    child: Text(
                      '${_tabs[_activeTab]} - segera hadir',
                      style: AppTextStyles.caption,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
