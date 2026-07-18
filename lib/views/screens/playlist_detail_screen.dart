import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/player_controller.dart';
import '../../models/playlist_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../widgets/song_tile.dart';
import '../widgets/add_to_playlist_sheet.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final PlaylistModel playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(playerControllerProvider).currentSong;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ---------- Header ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 18, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary, size: 20),
                  ),
                  Text('My Playlist', style: AppTextStyles.subheading),
                  const Icon(Icons.add, color: AppColors.textPrimary),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                children: [
                  const SizedBox(height: 20),
                  // ---------- Cover besar ----------
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: playlist.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: playlist.color.withOpacity(0.6), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: playlist.color.withOpacity(0.4),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(playlist.icon, color: playlist.color, size: 56),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Text(playlist.name, style: AppTextStyles.heading),
                        const SizedBox(height: 4),
                        Text('${playlist.songCount} songs',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---------- Play All / Shuffle ----------
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (playlist.songs.isNotEmpty) {
                              ref
                                  .read(playerControllerProvider.notifier)
                                  .playSong(playlist.songs.first);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Play All'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (playlist.songs.isNotEmpty) {
                              final shuffled = [...playlist.songs]..shuffle();
                              ref
                                  .read(playerControllerProvider.notifier)
                                  .playSong(shuffled.first);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.divider),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                          ),
                          icon: const Icon(Icons.shuffle),
                          label: const Text('Shuffle'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ---------- Daftar lagu ----------
                  for (int i = 0; i < playlist.songs.length; i++)
                    SongTile(
                      index: i + 1,
                      song: playlist.songs[i],
                      isPlaying: currentSong?.id == playlist.songs[i].id,
                      onTap: () => ref
                          .read(playerControllerProvider.notifier)
                          .playSong(playlist.songs[i]),
                      onMoreTap: () => showAddToPlaylistSheet(
                          context, playlist.songs[i]),
                    ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}