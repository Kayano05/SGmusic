import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class BilibiliService {
  static const String _baseUrl = 'https://api.bilibili.com';
  static const int _maxRetries = 3;

  static Map<String, String> get _headers => {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Referer': 'https://www.bilibili.com',
    'Origin': 'https://www.bilibili.com',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Encoding': 'gzip, deflate, br',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
    'Connection': 'keep-alive',
  };

  static Future<http.Response> _getWithRetry(String url, {
    Map<String, String>? headers,
    int retryCount = 0,
  }) async {
    try {
      print('Trying to request: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          ..._headers,
          ...?headers,
        },
      ).timeout(
        const Duration(seconds: 15),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return response;
    } on SocketException catch (e) {
      print('SocketException: ${e.message}');
      if (retryCount < _maxRetries) {
        print('Retrying... Attempt ${retryCount + 1}');
        await Future.delayed(Duration(seconds: retryCount + 1));
        return _getWithRetry(url, headers: headers, retryCount: retryCount + 1);
      }
      throw Exception('网络连接失败，请检查网络设置：${e.message}');
    } on TimeoutException {
      print('TimeoutException occurred');
      if (retryCount < _maxRetries) {
        print('Retrying... Attempt ${retryCount + 1}');
        await Future.delayed(Duration(seconds: retryCount + 1));
        return _getWithRetry(url, headers: headers, retryCount: retryCount + 1);
      }
      throw Exception('请求超时，请稍后重试');
    } catch (e) {
      print('Other error: $e');
      throw Exception('网络请求失败：$e');
    }
  }

  static Future<Map<String, dynamic>> getVideoInfo(String bvid) async {
    try {
      final url = '$_baseUrl/x/web-interface/view?bvid=$bvid&jsonp=jsonp';
      print('Getting video info from: $url');
      final response = await _getWithRetry(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 0) {
          return data['data'];
        } else {
          throw Exception('获取视频信息失败：${data['message']}');
        }
      } else {
        throw Exception('服务器响应错误：${response.statusCode}');
      }
    } catch (e) {
      print('Error in getVideoInfo: $e');
      throw Exception('获取视频信息失败：$e');
    }
  }

  static Future<String> getAudioUrl(String bvid) async {
    try {
      final videoInfo = await getVideoInfo(bvid);
      final cid = videoInfo['cid'];
      
      final url = '$_baseUrl/x/player/playurl?bvid=$bvid&cid=$cid&qn=0&fnval=16&fourk=1&platform=html5';
      print('Getting audio URL from: $url');
      final response = await _getWithRetry(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 0) {
          final dashData = data['data']['dash'];
          if (dashData != null && dashData['audio'] != null && dashData['audio'].isNotEmpty) {
            return dashData['audio'][0]['baseUrl'];
          }
          
          // 尝试获取其他格式的音频
          final durl = data['data']['durl'];
          if (durl != null && durl.isNotEmpty) {
            return durl[0]['url'];
          }

          throw Exception('未找到可用的音频流');
        } else {
          print('API返回错误: ${data['message']}');  // 添加日志
          throw Exception('获取音频地址失败：${data['message']}');
        }
      } else {
        print('HTTP状态码错误: ${response.statusCode}');  // 添加日志
        print('响应内容: ${response.body}');  // 添加日志
        throw Exception('服务器响应错误：${response.statusCode}');
      }
    } catch (e, stackTrace) {  // 添加堆栈跟踪
      print('Error in getAudioUrl: $e');
      print('Stack trace: $stackTrace');  // 打印堆栈跟踪
      throw Exception('获取音频地址失败：$e');
    }
  }
} 