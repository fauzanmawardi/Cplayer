import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State pengaturan aplikasi (masih dummy - belum benar2 mengubah tema
/// aplikasi secara real, hanya untuk kebutuhan tampilan Settings screen).
class SettingsState {
  final bool isDarkMode;
  final String language;

  const SettingsState({
    this.isDarkMode = true,
    this.language = 'English',
  });

  SettingsState copyWith({bool? isDarkMode, String? language}) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState());

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void setLanguage(String language) {
    state = state.copyWith(language: language);
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController();
});
