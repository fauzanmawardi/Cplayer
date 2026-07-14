import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart' as vp;
import '../models/video_model.dart';
import '../utils/app_colors.dart';

/// Controller: mengelola daftar video ASLI yang diimport dari device.
class VideoController extends StateNotifier<List<VideoModel>> {
  VideoController() : super([]);

  String _category = 'All';
  String get category => _category;

  List<VideoModel> get allVideos => state;

  List<VideoModel> get filteredVideos {
    if (_category == 'All') return state;
    return state.where((v) => v.category == _category).toList();
  }

  void setCategory(String category) {
    _category = category;
    state = [...state];
  }

  void toggleFavorite(String videoId) {
    state = [
      for (final video in state)
        if (video.id == videoId)
          video.copyWith(isFavorite: !video.isFavorite)
        else
          video,
    ];
  }

  VideoModel? getById(String id) {
    try {
      return state.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  void removeVideo(String id) {
    state = state.where((v) => v.id != id).toList();
  }

  /// Buka file picker device untuk memilih 1/banyak file video,
  /// ambil durasi asli lewat video_player, lalu tambahkan ke daftar.
  Future<int> importFromDevice() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return 0;

    final existingIds = state.map((v) => v.id).toSet();
    final List<VideoModel> imported = [];

    for (final file in result.files) {
      final path = file.path;
      if (path == null || existingIds.contains(path)) continue;

      Duration? duration;
      final tempController = vp.VideoPlayerController.file(File(path));
      try {
        await tempController.initialize();
        duration = tempController.value.duration;
      } catch (_) {
        duration = null;
      } finally {
        await tempController.dispose();
      }

      final totalSeconds = duration?.inSeconds ?? 0;
      final minutes = totalSeconds ~/ 60;
      final seconds = (totalSeconds % 60).toString().padLeft(2, '0');

      final rawName = file.name.contains('.')
          ? file.name.substring(0, file.name.lastIndexOf('.'))
          : file.name;

      imported.add(
        VideoModel(
          id: path,
          title: rawName,
          category: 'Videos',
          quality: 'Device',
          duration: '$minutes:$seconds',
          durationSeconds: totalSeconds,
          thumbColor: AppColors
              .coverPalette[imported.length % AppColors.coverPalette.length],
          sourcePath: path,
        ),
      );
    }

    if (imported.isNotEmpty) {
      state = [...state, ...imported];
    }
    return imported.length;
  }
}

final videoControllerProvider =
    StateNotifierProvider<VideoController, List<VideoModel>>((ref) {
  return VideoController();
});