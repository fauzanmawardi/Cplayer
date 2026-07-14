import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/video_controller.dart';
import '../../controllers/video_player_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../widgets/video_tile.dart';
import 'video_player_screen.dart';

/// View: halaman daftar video (All/Movies/TV Shows/Videos).
class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key});

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  final List<String> _categories = const ['All', 'Movies', 'TV Shows', 'Videos'];

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
                const Icon(Icons.search, color: AppColors.textPrimary),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---------- Kategori (chip tabs) ----------
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final category = _categories[i];
                final isActive = category == activeCategory;
                return GestureDetector(
                  onTap: () => controller.setCategory(category),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.accent : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: AppTextStyles.caption.copyWith(
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // ---------- List video ----------
          Expanded(
            child: videos.isEmpty
                ? Center(
                    child: Text('Belum ada video di kategori ini',
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
