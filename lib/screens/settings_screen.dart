import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../services/bilibili_service.dart';
import '../models/track.dart';
import '../services/playlist_service.dart';
import '../services/theme_service.dart';
import 'package:dio/dio.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _bvController = TextEditingController();
  bool _isLoading = false;
  double _downloadProgress = 0;
  bool _isDownloading = false;
  bool _isBatchDownloading = false;
  int _currentDownloadIndex = 0;
  int _totalDownloads = 0;

  Future<void> _downloadAudio() async {
    if (_bvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入BV号')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      final videoInfo = await BilibiliService.getVideoInfo(_bvController.text);
      final title = videoInfo['title'];
      final audioUrl = await BilibiliService.getAudioUrl(_bvController.text);
      
      final directory = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${directory.path}/Music');
      if (!await musicDir.exists()) {
        await musicDir.create();
      }

      final cleanTitle = title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final file = File('${musicDir.path}/$cleanTitle.mp3');

      final dio = Dio();
      await dio.download(
        audioUrl,
        file.path,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Referer': 'https://www.bilibili.com'
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) {
        final TextEditingController titleController = TextEditingController(text: title);
        final TextEditingController artistController = TextEditingController(text: '');  // 空白供用户输入
        final result = await showDialog<Map<String, String>>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              '编辑歌曲信息',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: '歌曲名称',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: artistController,
                  decoration: InputDecoration(
                    labelText: '艺术家',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
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
          final finalTitle = result['title']?.trim().isNotEmpty == true 
              ? result['title']! 
              : title;
          final finalArtist = result['artist']?.trim().isNotEmpty == true 
              ? result['artist']! 
              : 'B站视频';  // 如果用户没有输入，使用默认值
          
          final track = Track(
            title: finalTitle,
            artist: finalArtist,  // 使用用户输入的艺术家名称
            filePath: file.path,
            coverUrl: videoInfo['pic'],
            bvid: _bvController.text,
          );
          
          final playlistService = await PlaylistService.getInstance();
          await playlistService.addTrackToAutoPlaylist(track);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('下载完成并已添加到自动播放列表')),
            );
            _bvController.clear();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('错误：$e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
        _isDownloading = false;
        _downloadProgress = 0;
      });
    }
  }

  Future<void> _batchDownloadFromFavorite() async {
    final TextEditingController fidController = TextEditingController();
    final TextEditingController playlistController = TextEditingController();
    bool createNewPlaylist = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            '从收藏夹导入',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fidController,
                decoration: InputDecoration(
                  labelText: '收藏夹ID (FID)',
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
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: createNewPlaylist,
                onChanged: (value) {
                  setState(() {
                    createNewPlaylist = value ?? false;
                  });
                },
                title: Text(
                  '同时创建新歌单',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                activeColor: Theme.of(context).primaryColor,
              ),
              if (createNewPlaylist) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: playlistController,
                  decoration: InputDecoration(
                    labelText: '歌单名称',
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
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '提示：在收藏夹链接中找到media_id参数即为FID',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'fid': fidController.text,
                'createPlaylist': createNewPlaylist,
                'playlistName': playlistController.text,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('开始导入'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result['fid'].isNotEmpty) {
      String? newPlaylistName;
      if (result['createPlaylist'] && result['playlistName'].isNotEmpty) {
        try {
          final playlistService = await PlaylistService.getInstance();
          await playlistService.createPlaylist(result['playlistName']);
          newPlaylistName = result['playlistName'];
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('创建歌单失败：$e')),
            );
            return;
          }
        }
      }

      setState(() {
        _isBatchDownloading = true;
        _currentDownloadIndex = 0;
        _downloadProgress = 0;
      });

      try {
        final videos = await BilibiliService.getFavoriteList(result['fid']);
        _totalDownloads = videos.length;

        for (var i = 0; i < videos.length; i++) {
          setState(() {
            _currentDownloadIndex = i;
          });

          try {
            final video = videos[i];
            final audioUrl = await BilibiliService.getAudioUrl(video['bvid']);
            
            final directory = await getApplicationDocumentsDirectory();
            final musicDir = Directory('${directory.path}/Music');
            if (!await musicDir.exists()) {
              await musicDir.create();
            }

            final cleanTitle = video['title'].replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
            final file = File('${musicDir.path}/$cleanTitle.mp3');

            final dio = Dio();
            await dio.download(
              audioUrl,
              file.path,
              options: Options(
                headers: {
                  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                  'Referer': 'https://www.bilibili.com'
                },
              ),
              onReceiveProgress: (received, total) {
                if (total != -1) {
                  setState(() {
                    _downloadProgress = received / total;
                  });
                }
              },
            );

            final track = Track(
              title: video['title'],
              artist: 'B站视频',
              filePath: file.path,
              coverUrl: video['pic'],
              bvid: video['bvid'],
            );
            
            final playlistService = await PlaylistService.getInstance();
            await playlistService.addTrackToAutoPlaylist(track);
            
            if (newPlaylistName != null) {
              await playlistService.addTrackToPlaylist(newPlaylistName, track);
            }
          } catch (e) {
            print('下载失败: ${videos[i]['title']} - $e');
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(
              newPlaylistName != null 
                  ? '批量下载完成，已添加到自动播放列表和"$newPlaylistName"'
                  : '批量下载完成，已添加到自动播放列表'
            )),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('错误：$e')),
          );
        }
      } finally {
        setState(() {
          _isBatchDownloading = false;
          _currentDownloadIndex = 0;
          _downloadProgress = 0;
        });
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
              child: Text('设置'),
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
                  'World peace',
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
          child: Column(
            children: [
              // 下载功能区域
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.video_library,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'B站音频下载',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _bvController,
                        decoration: InputDecoration(
                          hintText: '请输入BV号',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.link),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_isDownloading)
                              LinearProgressIndicator(
                                value: _downloadProgress,
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _downloadAudio,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '下载中 ${(_downloadProgress * 100).toInt()}%',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        '下载',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // ... 原有的下载按钮代码 ...
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isBatchDownloading ? null : _batchDownloadFromFavorite,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.playlist_add),
                              label: _isBatchDownloading
                                  ? Text('${_currentDownloadIndex + 1}/$_totalDownloads')
                                  : const Text('批量导入'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 主题设置
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.palette,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '主题设置',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ThemeService.themeNames.length,
                      itemBuilder: (context, index) {
                        return RadioListTile<int>(
                          value: index,
                          groupValue: ThemeService.instance.currentThemeIndex,
                          onChanged: (value) async {
                            await ThemeService.instance.setTheme(value!);
                            if (mounted) {
                              setState(() {});
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('主题已更新'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                          title: Text(ThemeService.themeNames[index]),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          dense: true,
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 其他设置项
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('关于'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'SGmusic',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.music_note),
                    children: const [
                      Text('一个简单的音乐播放器，支持B站音频下载。'),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _bvController.dispose();
    super.dispose();
  }
} 