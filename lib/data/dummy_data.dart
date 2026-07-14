import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../utils/app_colors.dart';

/// Catatan: List lagu & video SUDAH TIDAK dummy lagi - sekarang diisi
/// lewat import file asli dari device:
/// - MusicController.importFromDevice()
/// - VideoController.importFromDevice()
/// Yang masih tersisa di sini cuma kerangka Playlist (nama/ikon/warna).
class DummyData {
  DummyData._();

  // ================= PLAYLISTS =================
  // Kerangka playlist saja. "Favorites" (p1) diisi otomatis lewat
  // playlistsProvider di playlist_controller.dart (berdasarkan lagu
  // yang ditandai favorite).
  static final List<PlaylistModel> playlists = [
    PlaylistModel(
      id: 'p1',
      name: 'Favorites',
      icon: Icons.favorite,
      color: AppColors.favorite,
      songs: const [],
    ),
    PlaylistModel(
      id: 'p2',
      name: 'Chill Vibes',
      icon: Icons.nightlight_round,
      color: AppColors.coverPalette[2],
      songs: const [],
    ),
    PlaylistModel(
      id: 'p3',
      name: 'Workout',
      icon: Icons.fitness_center,
      color: AppColors.coverPalette[4],
      songs: const [],
    ),
    PlaylistModel(
      id: 'p4',
      name: 'Romantic',
      icon: Icons.favorite_border,
      color: AppColors.coverPalette[1],
      songs: const [],
    ),
  ];
}