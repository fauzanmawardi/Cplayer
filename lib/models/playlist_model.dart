import 'package:flutter/material.dart';
import 'song_model.dart';

/// Model: merepresentasikan 1 playlist (mis. "Favorites", "Chill Vibes").
class PlaylistModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<SongModel> songs;

  const PlaylistModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.songs,
  });

  int get songCount => songs.length;

  PlaylistModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    List<SongModel>? songs,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      songs: songs ?? this.songs,
    );
  }
}
