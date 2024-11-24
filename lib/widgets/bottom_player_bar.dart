import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_player_service.dart';
import '../models/track.dart';

class BottomPlayerBar extends StatefulWidget {
  const BottomPlayerBar({super.key});

  @override
  State<BottomPlayerBar> createState() => _BottomPlayerBarState();
}

class _BottomPlayerBarState extends State<BottomPlayerBar> {
  final AudioPlayerService _playerService = AudioPlayerService.instance;

  void _showPlayModeMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('顺序播放'),
            onTap: () {
              _playerService.setPlayMode(PlayMode.sequence);
              Navigator.pop(context);
            },
            trailing: _playerService.playMode == PlayMode.sequence
                ? const Icon(Icons.check, color: Colors.pink)
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.shuffle),
            title: const Text('随机播放'),
            onTap: () {
              _playerService.setPlayMode(PlayMode.random);
              Navigator.pop(context);
            },
            trailing: _playerService.playMode == PlayMode.random
                ? const Icon(Icons.check, color: Colors.pink)
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.repeat_one),
            title: const Text('单曲循环'),
            onTap: () {
              _playerService.setPlayMode(PlayMode.loop);
              Navigator.pop(context);
            },
            trailing: _playerService.playMode == PlayMode.loop
                ? const Icon(Icons.check, color: Colors.pink)
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: _playerService.playerStateStream,
      builder: (context, snapshot) {
        final Track? currentTrack = _playerService.currentTrack;
        final bool isPlaying = _playerService.isPlaying;

        if (currentTrack == null) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border(
              top: BorderSide(
                color: Colors.grey[800]!,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: currentTrack.coverUrl != null
                    ? Image.network(
                        currentTrack.coverUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 48,
                            height: 48,
                            color: Colors.grey[800],
                            child: const Icon(Icons.music_note),
                          );
                        },
                      )
                    : Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey[800],
                        child: const Icon(Icons.music_note),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentTrack.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      currentTrack.artist,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _playerService.playMode == PlayMode.loop
                      ? Icons.repeat_one
                      : _playerService.playMode == PlayMode.random
                          ? Icons.shuffle
                          : Icons.repeat,
                  color: _playerService.playMode != PlayMode.sequence
                      ? Theme.of(context).primaryColor
                      : null,
                ),
                onPressed: _showPlayModeMenu,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  if (isPlaying) {
                    _playerService.pause();
                  } else {
                    _playerService.resume();
                  }
                },
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () {
                  _playerService.playNext();
                },
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
    );
  }
} 