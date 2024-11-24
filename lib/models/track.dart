class Track {
  final String title;
  final String artist;
  final String filePath;
  final String? coverUrl;
  final DateTime addedAt;
  final String? bvid;

  Track({
    required this.title,
    this.artist = 'B站视频',
    required this.filePath,
    this.coverUrl,
    this.bvid,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'filePath': filePath,
      'coverUrl': coverUrl,
      'bvid': bvid,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      title: json['title'],
      artist: json['artist'],
      filePath: json['filePath'],
      coverUrl: json['coverUrl'],
      bvid: json['bvid'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }
} 