import 'package:flutter/material.dart';
import '../../models/video_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

/// Widget reusable: 1 card item video (dipakai di Video screen).
class VideoTile extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onLongPress;

  const VideoTile({
    super.key,
    required this.video,
    required this.onTap,
    this.onMoreTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Thumbnail placeholder dengan durasi badge
            Stack(
              children: [
                Container(
                  width: 90,
                  height: 60,
                  decoration: BoxDecoration(
                    color: video.thumbColor.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.videocam, color: video.thumbColor, size: 26),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.duration,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(video.title,
                      style: AppTextStyles.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(video.quality, style: AppTextStyles.caption),
                ],
              ),
            ),
            IconButton(
              onPressed: onMoreTap ?? onTap,
              icon: const Icon(Icons.more_vert,
                  color: AppColors.textSecondary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}