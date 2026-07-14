import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dummy_data.dart';
import '../models/video_model.dart';

/// Controller: mengelola state daftar video -> filter kategori tab
/// (All, Movies, TV Shows, Videos).
class VideoController extends StateNotifier<List<VideoModel>> {
  VideoController() : super(DummyData.videos);

  String _category = 'All';
  String get category => _category;

  List<VideoModel> get filteredVideos {
    if (_category == 'All') return state;
    return state.where((v) => v.category == _category).toList();
  }

  void setCategory(String category) {
    _category = category;
    state = [...state]; // trigger rebuild
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
}

final videoControllerProvider =
    StateNotifierProvider<VideoController, List<VideoModel>>((ref) {
  return VideoController();
});
