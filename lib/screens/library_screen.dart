import 'package:flutter/material.dart';
import '../services/playlist_service.dart';
import '../models/track.dart';
import '../models/playlist.dart';
import '../services/audio_player_service.dart';
import 'dart:io';
import '../widgets/modern_list_item.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Playlist> _playlists = [];
  final TextEditingController _playlistNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaylists() async {
    final playlistService = await PlaylistService.getInstance();
    setState(() {
      _playlists = playlistService.getAllPlaylists();
    });
  }

  Future<void> _createPlaylist() async {
    final name = _playlistNameController.text.trim();
    if (name.isEmpty) return;

    try {
      final playlistService = await PlaylistService.getInstance();
      await playlistService.createPlaylist(name);
      _playlistNameController.clear();
      await _loadPlaylists();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已创建播放列表：$name')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败：$e')),
        );
      }
    }
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '创建播放列表',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: TextField(
          controller: _playlistNameController,
          decoration: InputDecoration(
            hintText: '请输入播放列表名称',
            filled: true,
            fillColor: Theme.of(context).colorScheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: _createPlaylist,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '创建',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlaylist(Playlist playlist) async {
    if (playlist.name == 'auto') return;
    
    try {
      final playlistService = await PlaylistService.getInstance();
      await playlistService.deletePlaylist(playlist.name);
      await _loadPlaylists();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已删除歌单：${playlist.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败：$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
          expandedHeight: 150,
          flexibleSpace: FlexibleSpaceBar(
            title: const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text('资料库'),
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
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Against the genocide against Palestine',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Antony Blinken is a war criminal',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'The Palestinian people are not animals',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'occupation is a crime',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final playlist = _playlists[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaylistDetailScreen(playlist: playlist),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.playlist_play,
                        size: 32,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: Text(
                      playlist.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    subtitle: Text(
                      '${playlist.tracks.length} 首歌曲',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.7),
                      ),
                    ),
                    trailing: playlist.name != 'auto'
                        ? IconButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                builder: (context) => SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        title: const Text(
                                          '删除歌单',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: Theme.of(context).colorScheme.surface,
                                              title: Text(
                                                '删除歌单',
                                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                              ),
                                              content: Text(
                                                '确定要删除歌单"${playlist.name}"吗？\n此操作不可恢复。',
                                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('取消'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text(
                                                    '删除',
                                                    style: TextStyle(color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirmed == true) {
                                            await _deletePlaylist(playlist);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : null,
                  ),
                );
              },
              childCount: _playlists.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ElevatedButton.icon(
                onPressed: _showCreatePlaylistDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  '创建新歌单',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 播放列表详情页面
class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late List<Track> _tracks;

  @override
  void initState() {
    super.initState();
    _tracks = List.from(widget.playlist.tracks);
  }

  Future<void> _removeTrack(Track track) async {
    try {
      final playlistService = await PlaylistService.getInstance();
      
      if (widget.playlist.name == 'auto') {
        final file = File(track.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      await playlistService.removeTrackFromPlaylist(
        widget.playlist.name,
        track,
      );
      
      setState(() {
        _tracks.remove(track);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.playlist.name == 'auto' 
                  ? '已删除歌曲和音频文件' 
                  : '已从播放列表中移除'
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败：$e')),
        );
      }
    }
  }

  Future<void> _showAddToPlaylistDialog(Track track) async {
    final playlistService = await PlaylistService.getInstance();
    final playlists = playlistService.getAllPlaylists()
      .where((p) => p.name != widget.playlist.name && p.name != 'auto')
      .toList();

    if (!mounted) return;

    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有其他可用的播放列表')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加到播放列表'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return ListTile(
                title: Text(playlist.name),
                onTap: () async {
                  try {
                    await playlistService.addTrackToPlaylist(
                      playlist.name,
                      track,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('已添加到播放列表：${playlist.name}'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('添加失败：$e')),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('��消'),
          ),
        ],
      ),
    );
  }

  Future<void> _editTrackInfo(Track track) async {
    final TextEditingController titleController = TextEditingController(text: track.title);
    final TextEditingController artistController = TextEditingController(text: track.artist);
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('编辑歌曲信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: '歌曲名称',
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 16),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: artistController,
              decoration: InputDecoration(
                labelText: '艺术家',
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'title': titleController.text,
              'artist': artistController.text,
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '确定',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      final newTitle = result['title']?.trim();
      final newArtist = result['artist']?.trim();
      if ((newTitle != null && newTitle.isNotEmpty) || 
          (newArtist != null && newArtist.isNotEmpty)) {
        final newTrack = Track(
          title: newTitle?.isNotEmpty == true ? newTitle! : track.title,
          artist: newArtist?.isNotEmpty == true ? newArtist! : track.artist,
          filePath: track.filePath,
          coverUrl: track.coverUrl,
          bvid: track.bvid,
          addedAt: track.addedAt,
        );

        try {
          final playlistService = await PlaylistService.getInstance();
          await playlistService.updateTrack(widget.playlist.name, track, newTrack);
          setState(() {
            final index = _tracks.indexOf(track);
            if (index != -1) {
              _tracks[index] = newTrack;
            }
          });
          
          AudioPlayerService.instance.updateCurrentTrack(newTrack);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('歌曲信息已更新')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('更新失败：$e')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
      ),
      body: ListView.builder(
        itemCount: _tracks.length,
        itemBuilder: (context, index) {
          final track = _tracks[index];
          final isPlaying = AudioPlayerService.instance.currentTrack?.filePath == track.filePath;
          
          return ModernTrackListItem(
            track: track,
            isPlaying: isPlaying,
            onTap: () {
              AudioPlayerService.instance.play(
                track,
                playlist: _tracks,
              );
            },
            actions: [
              TrackActionButton(
                icon: Icons.edit,
                onPressed: () => _editTrackInfo(track),
              ),
              TrackActionButton(
                icon: Icons.playlist_add,
                onPressed: () => _showAddToPlaylistDialog(track),
              ),
              if (widget.playlist.name != 'auto')
                TrackActionButton(
                  icon: Icons.remove_circle_outline,
                  onPressed: () => _removeTrack(track),
                  color: Colors.red,
                ),
            ],
          );
        },
      ),
    );
  }
} 