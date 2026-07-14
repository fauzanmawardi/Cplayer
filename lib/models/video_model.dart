import 'package:flutter/material.dart';

/// Model: merepresentasikan 1 video.
/// [category] contoh: "Movies", "TV Shows", "Videos" (dipakai untuk filter tab).
/// [quality] contoh: "8K Video", "4K Video", "1080p".
class VideoModel {
  final String id;
  final String title;
  final String category;
  final String quality;
  final String duration; // format tampilan, mis. "12:45"
  final int durationSeconds;
  final Color thumbColor;
  final bool isFavorite;

  const VideoModel({
    required this.id,
    required this.title,
    required this.category,
    required this.quality,
    required this.duration,
    required this.durationSeconds,
    required this.thumbColor,
    this.isFavorite = false,
  });

  VideoModel copyWith({
    String? id,
    String? title,
    String? category,
    String? quality,
    String? duration,
    int? durationSeconds,
    Color? thumbColor,
    bool? isFavorite,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      quality: quality ?? this.quality,
      duration: duration ?? this.duration,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      thumbColor: thumbColor ?? this.thumbColor,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
