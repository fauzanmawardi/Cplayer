import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/video_controller.dart';
import '../../controllers/video_player_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../widgets/video_tile.dart';
import '../widgets/confirm_dialog.dart';
import 'video_player_screen.dart';

/// View: halaman daftar video (All/Movies/TV Shows/Videos).
class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key});

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  final List<String> _categories = const ['All', 'Movies', 'TV Shows', 'Videos'];

  Future<void> _importVideos(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );

    final count =
        await ref.read(videoControllerProvider.notifier).importFromDevice();

    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count > 0
              ? '$count video berhasil diimport'
              : 'Tidak ada video baru yang dipilih',
        ),
        backgroundColor: AppColors.surfaceLight,
      ),
    );
  }

  Future<void> _showSortSheet(BuildContext context) async {
    final controller = ref.read(videoControllerProvider.notifier);
    final current = controller.sortOption;

    final options = [
      _VideoSortItem(VideoSortOption.titleAsc, 'Nama (A-Z)', Icons.sort_by_alpha),
      _VideoSortItem(VideoSortOption.durationAsc, 'Durasi (terpendek dulu)',
          Icons.timer_outlined),
      _VideoSortItem(VideoSortOption.recentlyAdded, 'Terbaru Ditambah',
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
    final controller = ref.read(videoControllerProvider.notifier);
    ref.watch(videoControllerProvider); // supaya rebuild saat state berubah
    final activeCategory = controller.category;
    final videos = controller.filteredVideos;

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
                Text('Video', style: AppTextStyles.heading),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _importVideos(context),
                      child: const Icon(Icons.add_circle_outline,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _showSortSheet(context),
                      child: const Icon(Icons.sort,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---------- Kategori (chip tabs) ----------
          // SizedBox(
          //   height: 36,
          //   child: ListView.separated(
          //     padding: const EdgeInsets.symmetric(horizontal: 18),
          //     scrollDirection: Axis.horizontal,
          //     itemCount: _categories.length,
          //     separatorBuilder: (_, __) => const SizedBox(width: 10),
          //     itemBuilder: (context, i) {
          //       final category = _categories[i];
          //       final isActive = category == activeCategory;
          //       return GestureDetector(
          //         onTap: () => controller.setCategory(category),
          //         child: Container(
          //           padding:
          //               const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //           decoration: BoxDecoration(
          //             color: isActive ? AppColors.accent : AppColors.surface,
          //             borderRadius: BorderRadius.circular(20),
          //           ),
          //           child: Text(
          //             category,
          //             style: AppTextStyles.caption.copyWith(
          //               color: isActive
          //                   ? AppColors.textPrimary
          //                   : AppColors.textSecondary,
          //               fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          //             ),
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
          // const SizedBox(height: 12),

          // ---------- List video ----------
          Expanded(
            child: videos.isEmpty
                ? Center(
                    child: controller.allVideos.isEmpty
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.video_library_outlined,
                                    color: AppColors.textMuted, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada video.\nImport video dari device kamu dulu.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.caption,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => _importVideos(context),
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
                        : Text('Belum ada video di kategori ini',
                            style: AppTextStyles.caption),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: videos.length,
                    itemBuilder: (context, i) {
                      final video = videos[i];
                      return VideoTile(
                        video: video,
                        onTap: () {
                          ref
                              .read(videoPlayerControllerProvider.notifier)
                              .playVideo(video);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const VideoPlayerScreen(),
                            ),
                          );
                        },
                        onMoreTap: () => ref
                            .read(videoControllerProvider.notifier)
                            .toggleFavorite(video.id),
                        onLongPress: () async {
                          final confirmed = await showConfirmDialog(
                            context,
                            title: 'Hapus Video?',
                            message:
                                '"${video.title}" akan dihapus dari library CPlayer (file di device tidak ikut terhapus).',
                          );
                          if (confirmed) {
                            ref
                                .read(videoControllerProvider.notifier)
                                .removeVideo(video.id);
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

class _VideoSortItem {
  final VideoSortOption sortOption;
  final String label;
  final IconData icon;
  const _VideoSortItem(this.sortOption, this.label, this.icon);
}