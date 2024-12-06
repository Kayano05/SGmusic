import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/playlist.dart';
import '../models/track.dart';

class PlaylistService {
  static const String _autoPlaylistName = 'auto';
  static PlaylistService? _instance;
  late final String _playlistsPath;
  Map<String, Playlist> _playlists = {};

  PlaylistService._();

  static Future<PlaylistService> getInstance() async {
    if (_instance == null) {
      _instance = PlaylistService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    final directory = await getApplicationDocumentsDirectory();
    _playlistsPath = '${directory.path}/playlists.json';
    await _loadPlaylists();
    
    // 确保auto播放列表存在
    if (!_playlists.containsKey(_autoPlaylistName)) {
      _playlists[_autoPlaylistName] = Playlist(name: _autoPlaylistName);
      await _savePlaylists();
    }
  }

  Future<void> _loadPlaylists() async {
    try {
      final file = File(_playlistsPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        _playlists = json.map((key, value) =>
            MapEntry(key, Playlist.fromJson(value as Map<String, dynamic>)));
      }
    } catch (e) {
      print('Error loading playlists: $e');
      _playlists = {};
    }
  }

  Future<void> _savePlaylists() async {
    try {
      final file = File(_playlistsPath);
      final json = jsonEncode(
          _playlists.map((key, value) => MapEntry(key, value.toJson())));
      await file.writeAsString(json);
    } catch (e) {
      print('Error saving playlists: $e');
    }
  }

  Future<void> addTrackToAutoPlaylist(Track track) async {
    final autoPlaylist = _playlists[_autoPlaylistName]!;
    
    // 检查是否已存在（检查 bvid 或文件路径）
    final existingTrack = autoPlaylist.tracks.firstWhere(
      (t) => (track.bvid != null && t.bvid == track.bvid) || 
             (track.bvid == null && t.filePath == track.filePath),
      orElse: () => track,
    );

    // 如果找到的 track 就是传入的 track，说明不存在重复
    if (identical(existingTrack, track)) {
      autoPlaylist.tracks.add(track);
    } else {
      // 对于自动播放列表，我们更新现有的曲目
      final index = autoPlaylist.tracks.indexOf(existingTrack);
      autoPlaylist.tracks[index] = track;
    }
    
    await _savePlaylists();
  }

  Playlist? getAutoPlaylist() {
    return _playlists[_autoPlaylistName];
  }

  // 获取所有播放列表
  List<Playlist> getAllPlaylists() {
    return _playlists.values.toList();
  }

  // 创建新播放列表
  Future<void> createPlaylist(String name) async {
    if (_playlists.containsKey(name)) {
      throw Exception('播放列表名称已存在');
    }
    _playlists[name] = Playlist(name: name);
    await _savePlaylists();
  }

  // 删除播放列表
  Future<void> deletePlaylist(String name) async {
    if (name == _autoPlaylistName) {
      throw Exception('不能删除自动播放列表');
    }
    
    // 直接从 _playlists Map 中删除
    _playlists.remove(name);
    await _savePlaylists();
  }

  // 向指定播放列表添加歌曲
  Future<void> addTrackToPlaylist(String playlistName, Track track) async {
    final playlist = _playlists[playlistName];
    if (playlist == null) {
      throw Exception('播放列表不存在');
    }

    // 检查是否已存在（检查 bvid 或文件路径）
    final existingTrack = playlist.tracks.firstWhere(
      (t) => (track.bvid != null && t.bvid == track.bvid) || 
             (track.bvid == null && t.filePath == track.filePath),
      orElse: () => track,
    );

    // 如果找到的 track 就是传入的 track，说明不存在重复
    if (identical(existingTrack, track)) {
      playlist.tracks.add(track);
    } else {
      // 如果已存在，可以选择更新或者抛出异常
      throw Exception('歌曲已存在于播放列表中');
    }
    
    await _savePlaylists();
  }

  // 从播放列表中移除歌曲
  Future<void> removeTrackFromPlaylist(String playlistName, Track track) async {
    final playlist = _playlists[playlistName];
    if (playlist == null) {
      throw Exception('播放列表不存在');
    }

    playlist.tracks.removeWhere((t) => 
      t.bvid != null && track.bvid != null 
        ? t.bvid == track.bvid 
        : t.filePath == track.filePath
    );
    
    await _savePlaylists();
  }

  // 添加更新歌曲的方法
  Future<void> updateTrack(String playlistName, Track oldTrack, Track newTrack) async {
    final playlist = _playlists[playlistName];
    if (playlist == null) {
      throw Exception('播放列表不存在');
    }

    final index = playlist.tracks.indexWhere((t) => 
      t.bvid != null && oldTrack.bvid != null 
        ? t.bvid == oldTrack.bvid 
        : t.filePath == oldTrack.filePath
    );

    if (index == -1) {
      throw Exception('歌曲不存在');
    }

    playlist.tracks[index] = newTrack;
    await _savePlaylists();
  }
} 