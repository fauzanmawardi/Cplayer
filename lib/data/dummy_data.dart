import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../models/video_model.dart';
import '../models/playlist_model.dart';
import '../utils/app_colors.dart';

/// Sumber data dummy (simulasi backend/API/local database).
/// Nantinya controller cukup memanggil class ini,
/// jadi kalau suatu saat diganti API asli, cukup ubah di satu tempat ini.
class DummyData {
  DummyData._();

  // ================= SONGS =================
  static final List<SongModel> songs = [
    SongModel(
      id: 's1',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      duration: '3:20',
      durationSeconds: 200,
      coverColor: AppColors.coverPalette[0],
      isFavorite: true,
    ),
    SongModel(
      id: 's2',
      title: 'Survival',
      artist: 'Eminem',
      duration: '3:52',
      durationSeconds: 232,
      coverColor: AppColors.coverPalette[1],
    ),
    SongModel(
      id: 's3',
      title: "Don't Start Now",
      artist: 'Dua Lipa',
      duration: '3:03',
      durationSeconds: 183,
      coverColor: AppColors.coverPalette[2],
      isFavorite: true,
    ),
    SongModel(
      id: 's4',
      title: 'After Hours',
      artist: 'The Weeknd',
      duration: '3:58',
      durationSeconds: 238,
      coverColor: AppColors.coverPalette[0],
    ),
    SongModel(
      id: 's5',
      title: 'About Damn Time',
      artist: 'Lizzo',
      duration: '3:11',
      durationSeconds: 191,
      coverColor: AppColors.coverPalette[3],
    ),
    SongModel(
      id: 's6',
      title: 'As It Was',
      artist: 'Harry Styles',
      duration: '2:47',
      durationSeconds: 167,
      coverColor: AppColors.coverPalette[4],
      isFavorite: true,
    ),
    SongModel(
      id: 's7',
      title: 'Be Alright',
      artist: 'Dean Lewis',
      duration: '3:16',
      durationSeconds: 196,
      coverColor: AppColors.coverPalette[5],
    ),
    SongModel(
      id: 's8',
      title: 'Butter',
      artist: 'BTS',
      duration: '2:44',
      durationSeconds: 164,
      coverColor: AppColors.coverPalette[6],
    ),
    SongModel(
      id: 's9',
      title: 'Save Your Tears',
      artist: 'The Weeknd',
      duration: '3:35',
      durationSeconds: 215,
      coverColor: AppColors.coverPalette[0],
    ),
  ];

  // Ditampilkan di Home > "Recently Played"
  static List<SongModel> get recentlyPlayed => [
        songs[0], // Blinding Lights
        songs[1], // Survival
        songs[2], // Don't Start Now
      ];

  // ================= VIDEOS =================
  static final List<VideoModel> videos = [
    VideoModel(
      id: 'v1',
      title: 'Nature Beauty',
      category: 'Videos',
      quality: '8K Video',
      duration: '12:45',
      durationSeconds: 765,
      thumbColor: AppColors.coverPalette[2],
      isFavorite: true,
    ),
    VideoModel(
      id: 'v2',
      title: 'The Ocean',
      category: 'Videos',
      quality: '4K Video',
      duration: '08:32',
      durationSeconds: 512,
      thumbColor: AppColors.coverPalette[7],
    ),
    VideoModel(
      id: 'v3',
      title: 'City Timelapse',
      category: 'Videos',
      quality: '4K Video',
      duration: '03:15',
      durationSeconds: 195,
      thumbColor: AppColors.coverPalette[3],
    ),
    VideoModel(
      id: 'v4',
      title: 'Football Highlights',
      category: 'TV Shows',
      quality: '1080p',
      duration: '10:21',
      durationSeconds: 621,
      thumbColor: AppColors.coverPalette[4],
    ),
    VideoModel(
      id: 'v5',
      title: 'Concert Live',
      category: 'Movies',
      quality: '1080p',
      duration: '15:20',
      durationSeconds: 920,
      thumbColor: AppColors.coverPalette[1],
    ),
  ];

  // ================= PLAYLISTS =================
  static final List<PlaylistModel> playlists = [
    PlaylistModel(
      id: 'p1',
      name: 'Favorites',
      icon: Icons.favorite,
      color: AppColors.favorite,
      songs: songs.where((s) => s.isFavorite).toList() +
          [songs[3], songs[6], songs[7], songs[8]], // total mendekati 32
    ),
    PlaylistModel(
      id: 'p2',
      name: 'Chill Vibes',
      icon: Icons.nightlight_round,
      color: AppColors.coverPalette[2],
      songs: [songs[6], songs[8], songs[4]],
    ),
    PlaylistModel(
      id: 'p3',
      name: 'Workout',
      icon: Icons.fitness_center,
      color: AppColors.coverPalette[4],
      songs: [songs[1], songs[0], songs[5], songs[2]],
    ),
    PlaylistModel(
      id: 'p4',
      name: 'Romantic',
      icon: Icons.favorite_border,
      color: AppColors.coverPalette[1],
      songs: [songs[2], songs[5], songs[3]],
    ),
  ];
}
