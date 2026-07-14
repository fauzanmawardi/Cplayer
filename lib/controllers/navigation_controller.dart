import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller: index tab yang sedang aktif di bottom navigation.
/// 0 = Home, 1 = Music, 2 = Video, 3 = Playlist, 4 = More/Settings
final navigationControllerProvider = StateProvider<int>((ref) => 0);
