import 'package:flutter/material.dart';

class SongModel {
  final String id;
  final String title;
  final String artist;
  final String duration; // format tampilan, mis. "3:20"
  final int durationSeconds; // dipakai untuk seekbar/progress
  final Color coverColor;
  final bool isFavorite;
  final String audioUrl;
  final DateTime addedAt;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.durationSeconds,
    required this.coverColor,
    required this.audioUrl,
    DateTime? addedAt,
    this.isFavorite = false,
  }) : addedAt = addedAt ?? DateTime.now();

  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? duration,
    int? durationSeconds,
    Color? coverColor,
    bool? isFavorite,
    String? audioUrl,
    DateTime? addedAt,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      coverColor: coverColor ?? this.coverColor,
      isFavorite: isFavorite ?? this.isFavorite,
      audioUrl: audioUrl ?? this.audioUrl,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}