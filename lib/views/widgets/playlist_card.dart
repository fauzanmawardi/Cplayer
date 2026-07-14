import 'package:flutter/material.dart';
import '../../models/playlist_model.dart';
import '../../utils/app_text_styles.dart';

/// Widget reusable: card playlist (cover ikon, nama, jumlah lagu).
class PlaylistCard extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: playlist.color.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(playlist.icon, color: playlist.color, size: 34),
            ),
            const SizedBox(height: 8),
            Text(playlist.name,
                style: AppTextStyles.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text('${playlist.songCount} songs', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
