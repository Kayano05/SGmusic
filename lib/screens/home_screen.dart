import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_player_service.dart';
import '../models/track.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final AudioPlayerService playerService = AudioPlayerService.instance;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
          expandedHeight: 100,
          flexibleSpace: FlexibleSpaceBar(
            title: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: const Text('音乐'),
            ),
            titlePadding: const EdgeInsetsDirectional.only(
              start: 0,
              bottom: 16,
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  'Save the Children of Gaza',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: StreamBuilder<PlayerState>(
            stream: playerService.playerStateStream,
            builder: (context, snapshot) {
              final Track? currentTrack = playerService.currentTrack;

              if (currentTrack == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.music_note,
                        size: 100,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '还没有播放的音乐',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    // 封面区域
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: currentTrack.coverUrl != null
                              ? Image.network(
                                  currentTrack.coverUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[900],
                                      child: const Icon(
                                        Icons.music_note,
                                        size: 80,
                                        color: Colors.white54,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey[900],
                                  child: const Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: Colors.white54,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    // 歌曲信息
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          Text(
                            currentTrack.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentTrack.artist,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[400],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // 进度条
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                      child: StreamBuilder<Duration?>(
                        stream: playerService.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          return StreamBuilder<Duration?>(
                            stream: playerService.durationStream,
                            builder: (context, snapshot) {
                              final duration = snapshot.data ?? Duration.zero;
                              return Column(
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 4,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                      overlayShape: const RoundSliderOverlayShape(
                                        overlayRadius: 14,
                                      ),
                                      activeTrackColor: Theme.of(context).primaryColor,
                                      inactiveTrackColor: Colors.grey[800],
                                      thumbColor: Theme.of(context).primaryColor,
                                      overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                    ),
                                    child: Slider(
                                      value: position.inMilliseconds.toDouble(),
                                      min: 0,
                                      max: duration.inMilliseconds.toDouble(),
                                      onChanged: (value) {
                                        playerService.seekTo(Duration(milliseconds: value.round()));
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(position),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                        Text(
                                          _formatDuration(duration),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // 控制按钮
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: AnimatedBuilder(
                              animation: playerService,
                              builder: (context, child) => Icon(
                                Icons.shuffle,
                                color: playerService.playMode == PlayMode.random
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            iconSize: 24,
                            onPressed: () {
                              if (playerService.playMode == PlayMode.random) {
                                playerService.setPlayMode(PlayMode.sequence);
                              } else {
                                playerService.setPlayMode(PlayMode.random);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            iconSize: 40,
                            color: Theme.of(context).colorScheme.onBackground,
                            onPressed: () => playerService.playPrevious(),
                          ),
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                playerService.isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 40,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              onPressed: () {
                                if (playerService.isPlaying) {
                                  playerService.pause();
                                } else {
                                  playerService.resume();
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            iconSize: 40,
                            color: Theme.of(context).colorScheme.onBackground,
                            onPressed: () => playerService.playNext(),
                          ),
                          IconButton(
                            icon: AnimatedBuilder(
                              animation: playerService,
                              builder: (context, child) => Icon(
                                playerService.playMode == PlayMode.loop
                                    ? Icons.repeat_one
                                    : Icons.repeat,
                                color: playerService.playMode == PlayMode.loop
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            iconSize: 24,
                            onPressed: () {
                              if (playerService.playMode == PlayMode.loop) {
                                playerService.setPlayMode(PlayMode.sequence);
                              } else {
                                playerService.setPlayMode(PlayMode.loop);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 