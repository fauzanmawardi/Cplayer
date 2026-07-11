class Playlist {
  final String id;
  final String name;
  final List<String> mediaItemIds;

  Playlist({
    required this.id,
    required this.name,
    List<String>? mediaItemIds,
  }) : mediaItemIds = mediaItemIds ?? [];

  Playlist copyWith({String? name, List<String>? mediaItemIds}) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      mediaItemIds: mediaItemIds ?? this.mediaItemIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mediaItemIds': mediaItemIds,
      };

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      mediaItemIds: List<String>.from(json['mediaItemIds'] as List),
    );
  }
}