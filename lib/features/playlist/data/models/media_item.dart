enum MediaType { audio, video }

enum MediaSource { local, network }

class MediaItem {
  final String id;
  final String title;
  final String path;
  final MediaType type;
  final MediaSource source;

  MediaItem({
    required this.id,
    required this.title,
    required this.path,
    required this.type,
    required this.source,
  });

  bool get isLocal => source == MediaSource.local;
  bool get isNetwork => source == MediaSource.network;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'path': path,
        'type': type.name,
        'source': source.name,
      };

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      path: json['path'] as String,
      type: MediaType.values.byName(json['type'] as String),
      source: MediaSource.values.byName(json['source'] as String),
    );
  }

  @override
  String toString() => 'MediaItem($title, $type, $source)';
}