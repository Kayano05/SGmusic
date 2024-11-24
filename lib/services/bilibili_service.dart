import 'package:http/http.dart' as http;
import 'dart:convert';

class BilibiliService {
  static const String _baseUrl = 'https://api.bilibili.com/x/web-interface/view';

  // 获取视频信息
  static Future<Map<String, dynamic>> getVideoInfo(String bvid) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?bvid=$bvid'),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['code'] == 0) {
        return data['data'];
      } else {
        throw Exception('获取视频信息失败：${data['message']}');
      }
    } else {
      throw Exception('网络请求失败');
    }
  }

  // 获取视频音频流地址
  static Future<String> getAudioUrl(String bvid) async {
    try {
      final videoInfo = await getVideoInfo(bvid);
      final cid = videoInfo['cid'];
      
      // 获取音频流地址
      final playUrlResponse = await http.get(
        Uri.parse('https://api.bilibili.com/x/player/playurl?bvid=$bvid&cid=$cid&fnval=16'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        },
      );

      if (playUrlResponse.statusCode == 200) {
        final playData = json.decode(playUrlResponse.body);
        if (playData['code'] == 0) {
          // 获取最高质量的音频流
          final audioUrl = playData['data']['dash']['audio'][0]['baseUrl'];
          return audioUrl;
        } else {
          throw Exception('获取音频地址失败：${playData['message']}');
        }
      } else {
        throw Exception('获取音频地址失败');
      }
    } catch (e) {
      throw Exception('处理失败：$e');
    }
  }
} 