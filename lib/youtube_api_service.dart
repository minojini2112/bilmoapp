import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'models/video_model.dart';

class YouTubeApiService {
  // YouTube API key from configuration
  static const String _apiKey = Config.youtubeApiKey;
  
  // YouTube Data API v3 base URL
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  
  // Search for YouTube Shorts related to a product - New implementation
  static Future<List<VideoModel>> searchShortsNew(String productQuery) async {
    try {
      print('🔍 Searching YouTube Shorts for: $productQuery');
      
      // Enhanced search query for better shorts results
      final enhancedQuery = '$productQuery #shorts review unboxing';
      final encodedQuery = Uri.encodeComponent(enhancedQuery);
      
      // YouTube API search endpoint
      final url = '$_baseUrl/search?part=snippet&q=$encodedQuery&type=${Config.searchType}&videoDuration=${Config.videoDuration}&maxResults=${Config.maxResults}&key=$_apiKey';
      
      print('🔗 YouTube API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('📡 YouTube API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        
        print('📊 Found ${items.length} YouTube Shorts');
        
        // Convert to VideoModel objects
        List<VideoModel> videos = [];
        for (var item in items) {
          try {
            final video = VideoModel.fromJson(item as Map<String, dynamic>);
            videos.add(video);
          } catch (e) {
            print('❌ Error parsing video: $e');
            continue;
          }
        }
        
        return videos;
      } else {
        print('❌ YouTube API Error: ${response.statusCode}');
        print('📄 Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ YouTube API request failed: $e');
      return [];
    }
  }

  // Search for YouTube Shorts related to a product - Legacy method
  static Future<List<Map<String, dynamic>>> searchShorts(String productQuery) async {
    try {
      print('🔍 Searching YouTube Shorts for: $productQuery');
      
      // Encode the search query
      final encodedQuery = Uri.encodeComponent('$productQuery shorts review unboxing');
      
      // YouTube API search endpoint
      final url = '$_baseUrl/search?part=snippet&q=$encodedQuery&type=${Config.searchType}&videoDuration=${Config.videoDuration}&maxResults=${Config.maxResults}&key=$_apiKey';
      
      print('🔗 YouTube API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('📡 YouTube API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        
        print('📊 Found ${items.length} YouTube Shorts');
        
        // Process the results
        List<Map<String, dynamic>> shorts = [];
        
        for (var item in items) {
          final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
          final videoId = item['id']['videoId'] as String? ?? '';
          
          // Get additional video details
          final videoDetails = await _getVideoDetails(videoId);
          
          shorts.add({
            'id': videoId,
            'title': snippet['title'] ?? 'Untitled',
            'description': snippet['description'] ?? '',
            'thumbnail': snippet['thumbnails']?['high']?['url'] ?? 
                        snippet['thumbnails']?['medium']?['url'] ?? 
                        snippet['thumbnails']?['default']?['url'] ?? '',
            'channelTitle': snippet['channelTitle'] ?? 'Unknown Channel',
            'publishedAt': snippet['publishedAt'] ?? '',
            'url': 'https://www.youtube.com/shorts/$videoId',
            'duration': videoDetails['duration'] ?? '',
            'viewCount': videoDetails['viewCount'] ?? '',
            'likeCount': videoDetails['likeCount'] ?? '',
          });
        }
        
        return shorts;
      } else {
        print('❌ YouTube API Error: ${response.statusCode}');
        print('📄 Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ YouTube API request failed: $e');
      return [];
    }
  }
  
  // Get additional video details like duration, view count, etc.
  static Future<Map<String, dynamic>> _getVideoDetails(String videoId) async {
    try {
      final url = '$_baseUrl/videos?part=contentDetails,statistics&id=$videoId&key=$_apiKey';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        
        if (items.isNotEmpty) {
          final item = items[0] as Map<String, dynamic>;
          final contentDetails = item['contentDetails'] as Map<String, dynamic>? ?? {};
          final statistics = item['statistics'] as Map<String, dynamic>? ?? {};
          
          return {
            'duration': _formatDuration(contentDetails['duration'] ?? ''),
            'viewCount': _formatNumber(statistics['viewCount'] ?? '0'),
            'likeCount': _formatNumber(statistics['likeCount'] ?? '0'),
          };
        }
      }
    } catch (e) {
      print('❌ Error getting video details: $e');
    }
    
    return {
      'duration': '',
      'viewCount': '',
      'likeCount': '',
    };
  }
  
  // Format duration from ISO 8601 to readable format
  static String _formatDuration(String duration) {
    if (duration.isEmpty) return '';
    
    // Remove PT prefix and parse duration
    final cleanDuration = duration.replaceAll('PT', '');
    
    // Parse duration manually since Dart doesn't support lookahead regex
    String result = '';
    
    // Extract hours
    final hourMatch = RegExp(r'(\d+)H').firstMatch(cleanDuration);
    if (hourMatch != null) {
      result += '${hourMatch.group(1)}h ';
    }
    
    // Extract minutes
    final minuteMatch = RegExp(r'(\d+)M').firstMatch(cleanDuration);
    if (minuteMatch != null) {
      result += '${minuteMatch.group(1)}m ';
    }
    
    // Extract seconds
    final secondMatch = RegExp(r'(\d+)S').firstMatch(cleanDuration);
    if (secondMatch != null) {
      result += '${secondMatch.group(1)}s';
    }
    
    return result.trim();
  }
  
  // Format large numbers (e.g., 1000000 -> 1M)
  static String _formatNumber(String numberStr) {
    try {
      final number = int.parse(numberStr);
      if (number >= 1000000) {
        return '${(number / 1000000).toStringAsFixed(1)}M';
      } else if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(1)}K';
      } else {
        return number.toString();
      }
    } catch (e) {
      return numberStr;
    }
  }
  
  // Test YouTube API connectivity
  static Future<bool> testConnectivity() async {
    try {
      final url = '$_baseUrl/search?part=snippet&q=test&type=video&maxResults=1&key=$_apiKey';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('🔍 YouTube API Test Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ YouTube API Test Failed: $e');
      return false;
    }
  }
}
