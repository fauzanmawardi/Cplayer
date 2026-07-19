// lib/controllers/background_controller.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/background_model.dart';

/// Controller: mengatur ambil, simpan, dan load background dari galeri.
class BackgroundController extends Notifier<BackgroundModel> {
  static const _prefKey = 'cplayer_bg_path';

  @override
  BackgroundModel build() {
    // Jalan otomatis saat provider pertama kali dibaca
    _loadSavedBackground();
    return const BackgroundModel();
  }

  Future<void> _loadSavedBackground() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_prefKey);
    if (path != null && File(path).existsSync()) {
      state = state.copyWith(imagePath: path);
    }
  }

  Future<void> pickFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'bg_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final saved = await File(picked.path).copy('${appDir.path}/$fileName');

    state = BackgroundModel(imagePath: saved.path);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, saved.path);
  }

  Future<void> resetToDefault() async {
    state = const BackgroundModel();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}

/// Provider global, dipakai lewat ref.watch / ref.read
final backgroundControllerProvider =
    NotifierProvider<BackgroundController, BackgroundModel>(
  BackgroundController.new,
);