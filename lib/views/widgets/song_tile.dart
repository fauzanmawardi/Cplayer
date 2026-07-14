import 'package:flutter/material.dart';
import '../../models/song_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

/// Widget reusable: 1 baris item lagu.
/// Dipakai di: Home (Recently Played), Music screen, Playlist detail.
class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;
  final int? index; // untuk nomor urut di playlist detail (opsional)
  final bool isPlaying;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onMoreTap,
    this.index,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            if (index != null) ...[
              SizedBox(
                width: 20,
                child: Text('$index', style: AppTextStyles.caption),
              ),
              const SizedBox(width: 8),
            ],
            // Thumbnail placeholder (warna solid + icon musik)
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: song.coverColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.music_note, color: song.coverColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: AppTextStyles.body.copyWith(
                      color: isPlaying ? AppColors.accent : AppColors.textPrimary,
                      fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(song.artist, style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(song.duration, style: AppTextStyles.caption),
            if (onMoreTap != null)
              IconButton(
                onPressed: onMoreTap,
                icon: const Icon(Icons.more_vert,
                    color: AppColors.textSecondary, size: 20),
              )
            else
              IconButton(
                onPressed: onTap,
                icon: Icon(
                  isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
