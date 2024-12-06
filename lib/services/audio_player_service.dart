import 'package:just_audio/just_audio.dart';
import '../models/track.dart';
import '../models/playlist.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

enum PlayMode {
  sequence,  // 顺序播放
  loop,      // 单曲循环
  random     // 随机播放
}

class AudioPlayerService extends ChangeNotifier {
  static AudioPlayerService? _instance;
  final AudioPlayer _player = AudioPlayer();
  Track? _currentTrack;
  List<Track>? _currentPlaylist;
  int _currentIndex = -1;
  PlayMode _playMode = PlayMode.sequence;
  final Random _random = Random();

  static AudioPlayerService get instance {
    _instance ??= AudioPlayerService._();
    return _instance!;
  }

  Track? get currentTrack => _currentTrack;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  bool get isPlaying => _player.playing;
  PlayMode get playMode => _playMode;

  AudioPlayerService._() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onPlaybackComplete();
      }
    });
  }

  Future<void> _onPlaybackComplete() async {
    if (_currentPlaylist == null || _currentIndex < 0) return;

    switch (_playMode) {
      case PlayMode.sequence:
        if (_currentPlaylist!.length == 1) {
          // 如果只有一首歌，重新播放当前歌曲
          await _player.seek(Duration.zero);
          await _player.play();
        } else {
          await playNext();
        }
        break;
      case PlayMode.loop:
        // 单曲循环由 setLoopMode 处理
        break;
      case PlayMode.random:
        if (_currentPlaylist!.length == 1) {
          // 如果只有一首歌，重新播放当前歌曲
          await _player.seek(Duration.zero);
          await _player.play();
        } else {
          await playRandom();
        }
        break;
    }
  }

  Future<void> playRandom() async {
    if (_currentPlaylist != null && _currentPlaylist!.isNotEmpty) {
      final excludeIndex = _currentIndex;
      int nextIndex;
      if (_currentPlaylist!.length > 1) {
        do {
          nextIndex = _random.nextInt(_currentPlaylist!.length);
        } while (nextIndex == excludeIndex);
      } else {
        nextIndex = 0;
      }
      final nextTrack = _currentPlaylist![nextIndex];
      await play(nextTrack, playlist: _currentPlaylist);
    }
  }

  Future<void> play(Track track, {List<Track>? playlist}) async {
    _currentPlaylist = playlist;
    if (playlist != null) {
      _currentIndex = playlist.indexWhere((t) => t.filePath == track.filePath);
    }
    
    if (_currentTrack?.filePath != track.filePath) {
      _currentTrack = track;
      await _player.setFilePath(track.filePath);
    }
    await _player.play();
  }

  Future<void> playNext() async {
    if (_currentPlaylist != null && _currentIndex >= 0) {
      if (_currentPlaylist!.length == 1) {
        // 如果只有一首歌，重新播放当前歌曲
        await _player.seek(Duration.zero);
        await _player.play();
      } else if (_playMode == PlayMode.random) {
        await playRandom();
      } else {
        final nextIndex = (_currentIndex + 1) % _currentPlaylist!.length;
        final nextTrack = _currentPlaylist![nextIndex];
        await play(nextTrack, playlist: _currentPlaylist);
      }
    }
  }

  Future<void> playPrevious() async {
    if (_currentPlaylist != null && _currentIndex >= 0) {
      if (_currentPlaylist!.length == 1) {
        // 如果只有一首歌，重新播放当前歌曲
        await _player.seek(Duration.zero);
        await _player.play();
      } else if (_playMode == PlayMode.random) {
        await playRandom();
      } else {
        final previousIndex = (_currentIndex - 1 + _currentPlaylist!.length) % _currentPlaylist!.length;
        final previousTrack = _currentPlaylist![previousIndex];
        await play(previousTrack, playlist: _currentPlaylist);
      }
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
    _currentTrack = null;
    _currentPlaylist = null;
    _currentIndex = -1;
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  Future<void> setPlayMode(PlayMode mode) async {
    _playMode = mode;
    if (mode == PlayMode.loop) {
      await _player.setLoopMode(LoopMode.one);
    } else {
      await _player.setLoopMode(LoopMode.off);
    }
    notifyListeners();
  }

  void updateCurrentTrack(Track newTrack) {
    if (_currentTrack?.filePath == newTrack.filePath) {
      _currentTrack = newTrack;
      notifyListeners();
    }
  }
} 