import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/music_controller.dart';
import '../../controllers/player_controller.dart';
import '../../models/song_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../widgets/song_tile.dart';
import '../widgets/add_to_playlist_sheet.dart';
import '../widgets/confirm_dialog.dart';

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
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _isSearching = true);
  }

  void _closeSearch() {
    _searchController.clear();
    ref.read(musicControllerProvider.notifier).search('');
    setState(() => _isSearching = false);
  }

  Future<void> _importSongs() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );

    final count =
        await ref.read(musicControllerProvider.notifier).importFromDevice();

    if (!mounted) return;
    Navigator.of(context).pop(); // tutup loading dialog

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count > 0
              ? '$count lagu berhasil diimport'
              : 'Tidak ada lagu baru yang dipilih',
        ),
        backgroundColor: AppColors.surfaceLight,
      ),
    );
  }

  Future<void> _showSortSheet() async {
    final controller = ref.read(musicControllerProvider.notifier);
    final current = controller.sortOption;

    final options = [
      _SortOptionItem(SortOption.titleAsc, 'Nama (A-Z)', Icons.sort_by_alpha),
      _SortOptionItem(SortOption.durationAsc, 'Durasi (terpendek dulu)',
          Icons.timer_outlined),
      _SortOptionItem(SortOption.recentlyAdded, 'Terbaru Ditambah',
          Icons.new_releases_outlined),
    ];

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Urutkan Berdasarkan',
                      style: AppTextStyles.subheading),
                ),
              ),
              const SizedBox(height: 8),
              for (final item in options)
                ListTile(
                  leading: Icon(item.icon, color: AppColors.textSecondary),
                  title: Text(item.label, style: AppTextStyles.body),
                  trailing: current == item.sortOption
                      ? const Icon(Icons.check, color: AppColors.accent)
                      : null,
                  onTap: () {
                    controller.setSortOption(item.sortOption);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(musicControllerProvider); // trigger rebuild saat search/favorite berubah
    final musicController = ref.read(musicControllerProvider.notifier);
    final songs = musicController.filteredSongs;
    final currentSong = ref.watch(playerControllerProvider).currentSong;

    // Kelompokkan per huruf HANYA kalau sedang sort "Nama (A-Z)".
    // Untuk sort Durasi / Terbaru Ditambah, tampil sebagai list biasa
    // mengikuti urutan dari controller (grouping per huruf tidak relevan).
    final isGroupedByName = musicController.sortOption == SortOption.titleAsc;
    final Map<String, List<SongModel>> grouped = {};
    if (isGroupedByName) {
      for (final song in songs) {
        final letter = song.title.substring(0, 1).toUpperCase();
        grouped.putIfAbsent(letter, () => []).add(song);
      }
    }

    return SafeArea(
      child: Column(
        children: [
          // ---------- Header ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: _isSearching
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: AppTextStyles.body,
                          cursorColor: AppColors.accent,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Cari judul atau artis...',
                            hintStyle: AppTextStyles.caption,
                            border: InputBorder.none,
                          ),
                          onChanged: (value) => ref
                              .read(musicControllerProvider.notifier)
                              .search(value),
                        ),
                      ),
                      IconButton(
                        onPressed: _closeSearch,
                        icon: const Icon(Icons.close,
                            color: AppColors.textPrimary),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.menu_rounded,
                          color: AppColors.textPrimary),
                      Text('Music', style: AppTextStyles.heading),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _importSongs,
                            child: const Icon(Icons.add_circle_outline,
                                color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _showSortSheet,
                            child: const Icon(Icons.sort,
                                color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _openSearch,
                            child: const Icon(Icons.search,
                                color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),

          // ---------- Tabs ----------
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 18),
          //   child: Row(
          //     children: List.generate(_tabs.length, (i) {
          //       final isActive = i == _activeTab;
          //       return Padding(
          //         padding: const EdgeInsets.only(right: 22),
          //         child: GestureDetector(
          //           onTap: () => setState(() => _activeTab = i),
          //           child: Column(
          //             children: [
          //               Text(
          //                 _tabs[i],
          //                 style: AppTextStyles.body.copyWith(
          //                   color: isActive
          //                       ? AppColors.favorite
          //                       : AppColors.textSecondary,
          //                   fontWeight:
          //                       isActive ? FontWeight.w600 : FontWeight.w400,
          //                 ),
          //               ),
          //               const SizedBox(height: 6),
          //               if (isActive)
          //                 Container(
          //                   height: 2,
          //                   width: 24,
          //                   color: AppColors.favorite,
          //                 ),
          //             ],
          //           ),
          //         ),
          //       );
          //     }),
          //   ),
          // ),
          // const Divider(color: AppColors.divider, height: 20),

          // ---------- Konten ----------
          Expanded(
            child: _activeTab == 0
                ? (songs.isEmpty
                    ? Center(
                        child: musicController.allSongs.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.library_music_outlined,
                                        color: AppColors.textMuted, size: 48),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Belum ada lagu.\nImport lagu dari device kamu dulu.',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.caption,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: _importSongs,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24)),
                                      ),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Import dari Device'),
                                    ),
                                  ],
                                ),
                              )
                            : Text('Lagu tidak ditemukan',
                                style: AppTextStyles.caption),
                      )
                    : ListView(
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
                            final random = [...songs]..shuffle();
                            ref
                                .read(playerControllerProvider.notifier)
                                .playSong(random.first);
                          }
                        },
                      ),
                      const SizedBox(height: 4),

                      // List lagu: dikelompokkan per huruf (sort Nama),
                      // atau list biasa (sort Durasi / Terbaru Ditambah)
                      if (isGroupedByName)
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
                              onMoreTap: () =>
                                  showAddToPlaylistSheet(context, song),
                              onLongPress: () async {
                                final confirmed = await showConfirmDialog(
                                  context,
                                  title: 'Hapus Lagu?',
                                  message:
                                      '"${song.title}" akan dihapus dari library CPlayer (file di device tidak ikut terhapus).',
                                );
                                if (confirmed) {
                                  ref
                                      .read(musicControllerProvider.notifier)
                                      .removeSong(song.id);
                                }
                              },
                            ),
                        ]
                      else
                        for (final song in songs)
                          SongTile(
                            song: song,
                            isPlaying: currentSong?.id == song.id,
                            onTap: () => ref
                                .read(playerControllerProvider.notifier)
                                .playSong(song),
                            onMoreTap: () =>
                                showAddToPlaylistSheet(context, song),
                            onLongPress: () async {
                              final confirmed = await showConfirmDialog(
                                context,
                                title: 'Hapus Lagu?',
                                message:
                                    '"${song.title}" akan dihapus dari library CPlayer (file di device tidak ikut terhapus).',
                              );
                              if (confirmed) {
                                ref
                                    .read(musicControllerProvider.notifier)
                                    .removeSong(song.id);
                              }
                            },
                          ),
                      const SizedBox(height: 80),
                    ],
                  ))
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

class _SortOptionItem {
  final SortOption sortOption;
  final String label;
  final IconData icon;
  const _SortOptionItem(this.sortOption, this.label, this.icon);
}