import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/music_controller.dart';
import '../../controllers/playlist_controller.dart';
import '../../models/song_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

/// Bottom sheet: pilih playlist custom mana saja yang mau diisi lagu ini,
/// plus toggle cepat "Favorite". Dipanggil dari tombol "more" di SongTile.
Future<void> showAddToPlaylistSheet(BuildContext context, SongModel song) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AddToPlaylistSheetBody(song: song),
  );
}

class _AddToPlaylistSheetBody extends ConsumerWidget {
  final SongModel song;
  const _AddToPlaylistSheetBody({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistControllerProvider);
    final playlistController = ref.read(playlistControllerProvider.notifier);

    // Favorites (p1) dikelola otomatis, jadi tidak ditampilkan sebagai
    // checkbox playlist biasa - cukup toggle hati terpisah di atas.
    final customPlaylists = playlists.where((p) => p.id != 'p1').toList();

    // Ambil status favorite terkini dari MusicController (bukan dari
    // objek `song` yang mungkin sudah basi/snapshot lama).
    // PENTING: watch provider list-nya (bukan .notifier) supaya widget
    // ini ikut rebuild saat status favorite berubah.
    final allSongs = ref.watch(musicControllerProvider);
    final liveSong =
        allSongs.firstWhere((s) => s.id == song.id, orElse: () => song);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: liveSong.coverColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.music_note, color: liveSong.coverColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(liveSong.title,
                          style: AppTextStyles.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(liveSong.artist, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: AppColors.divider, height: 24),

            // ---------- Toggle Favorite ----------
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: liveSong.isFavorite,
              onChanged: (_) => ref
                  .read(musicControllerProvider.notifier)
                  .toggleFavorite(liveSong.id),
              activeColor: AppColors.favorite,
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              title: Row(
                children: [
                  const Icon(Icons.favorite, color: AppColors.favorite, size: 20),
                  const SizedBox(width: 8),
                  Text('Favorites', style: AppTextStyles.body),
                ],
              ),
            ),

            Text('Tambah ke playlist lain',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.accent)),

            // ---------- Daftar playlist custom ----------
            for (final playlist in customPlaylists)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: playlistController.isSongInPlaylist(
                    playlist.id, liveSong.id),
                onChanged: (_) => playlistController.toggleSongInPlaylist(
                    playlist.id, liveSong),
                activeColor: AppColors.accent,
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
                title: Row(
                  children: [
                    Icon(playlist.icon, color: playlist.color, size: 20),
                    const SizedBox(width: 8),
                    Text(playlist.name, style: AppTextStyles.body),
                  ],
                ),
                subtitle: Text('${playlist.songCount} songs',
                    style: AppTextStyles.caption),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}