import 'track.dart';

class Playlist {
  final String name;
  final List<Track> tracks;
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist({
    required this.name,
    List<Track>? tracks,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : tracks = tracks ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      name: json['name'],
      tracks: (json['tracks'] as List)
          .map((trackJson) => Track.fromJson(trackJson))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
} 