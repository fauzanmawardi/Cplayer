import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/media_item.dart';

/// Repository bertanggung jawab atas semua akses data playlist:
/// file picker, dan (nanti) penyimpanan permanen ke disk.
/// Provider/UI tidak perlu tahu detail implementasinya.
class PlaylistRepository {
  final _uuid = const Uuid();

  Future<List<MediaItem>> pickLocalFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'mp3', 'wav', 'm4a', 'aac', 'flac',
        'mp4', 'mov', 'mkv', 'avi',
      ],
    );

    if (result == null) return [];

    final videoExt = {'mp4', 'mov', 'mkv', 'avi'};

    return result.files.where((f) => f.path != null).map((f) {
      final ext = (f.extension ?? '').toLowerCase();
      final type = videoExt.contains(ext) ? MediaType.video : MediaType.audio;
      return MediaItem(
        id: _uuid.v4(),
        title: f.name,
        path: f.path!,
        type: type,
        source: MediaSource.local,
      );
    }).toList();
  }

  MediaItem buildNetworkItem({
    required String url,
    required String title,
    required MediaType type,
  }) {
    return MediaItem(
      id: _uuid.v4(),
      title: title,
      path: url,
      type: type,
      source: MediaSource.network,
    );
  }

  // TODO: load() dan save() akan ditambahkan di sini untuk fitur
  // playlist tersimpan permanen (persistence).
}