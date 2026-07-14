import 'package:flutter/material.dart';

/// Model: merepresentasikan 1 lagu.
/// Karena scope saat ini masih dummy data (belum ada file audio asli),
/// [coverColor] dipakai sebagai pengganti thumbnail/cover art.
class SongModel {
  final String id;
  final String title;
  final String artist;
  final String duration; // format tampilan, mis. "3:20"
  final int durationSeconds; // dipakai untuk seekbar/progress
  final Color coverColor;
  final bool isFavorite;

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.durationSeconds,
    required this.coverColor,
    this.isFavorite = false,
  });

  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? duration,
    int? durationSeconds,
    Color? coverColor,
    bool? isFavorite,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      coverColor: coverColor ?? this.coverColor,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
