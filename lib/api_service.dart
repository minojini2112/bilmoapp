import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiService {
  // Dynamic backend URL detection
  static List<String> getBackendUrls() {
    // Check if running on web (Chrome)
    if (kIsWeb) {
      return [
        'http://localhost:5000', // Primary for web
        'http://127.0.0.1:5000', // Fallback for web
        'http://192.168.29.197:5000', // Your actual local network IP (Wi-Fi)
        'http://192.168.1.100:5000', // Your actual local network IP
      ];
    } else {
      // For mobile apps
      return [
        'http://127.0.0.1:5000', // ADB port forwarding (should work for USB devices)
        'http://localhost:5000', // ADB port forwarding alternative
        'http://10.0.2.2:5000', // Android emulator
        'http://192.168.1.100:5000', // Update this with your actual IP
        'http://192.168.29.197:5000', // Your actual local network IP (Wi-Fi)
      ];
    }
  }

  // Get the best working URL for web
  static Future<String?> getWorkingUrl() async {
    final urls = getBackendUrls();
    
    print('🔍 Testing connectivity for mobile device...');
    print('🌐 Platform: ${kIsWeb ? 'Web' : 'Mobile'}');
    print('🔗 URLs to test: $urls');
    
    for (String url in urls) {
      try {
        print('🔍 Testing: $url/test');
        // Try the test endpoint first
        final response = await http.get(
          Uri.parse('$url/test'),
          headers: {
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200) {
          print('✅ Found working URL: $url');
          return url;
        } else {
          print('⚠️ URL $url responded with status: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ URL $url failed: $e');
        print('🔍 Error type: ${e.runtimeType}');
        continue;
      }
    }
    
    print('❌ No working URLs found');
    return null;
  }

  // Search products API call
  static Future<Map<String, dynamic>?> searchProducts(String query) async {
    // For web, try to get a working URL first
    if (kIsWeb) {
      final workingUrl = await getWorkingUrl();
      if (workingUrl != null) {
        return await _makeSearchRequest(workingUrl, query);
      }
    }
    
    final List<String> possibleUrls = getBackendUrls();
    
    print('🔍 Starting search for: $query');
    print('🌐 Trying URLs: $possibleUrls');
    
    for (String baseUrl in possibleUrls) {
      try {
        print('🔍 Testing search API at: $baseUrl');
        
        // First test basic connectivity
        final testResponse = await http.get(
          Uri.parse('$baseUrl/'),
          headers: {
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
          },
        ).timeout(const Duration(seconds: 5));
        
        if (testResponse.statusCode == 200) {
          print('✅ Backend is reachable at: $baseUrl');
        } else {
          print('⚠️ Backend responded with status: ${testResponse.statusCode}');
        }
        
        final result = await _makeSearchRequest(baseUrl, query);
        if (result != null) {
          return result;
        }
      } catch (e) {
        print('❌ Failed to connect to $baseUrl: $e');
        print('🔍 Error type: ${e.runtimeType}');
        continue; // Try next URL
      }
    }
    
    print('❌ All backend URLs failed');
    return null;
  }

  // Helper method to make search request
  static Future<Map<String, dynamic>?> _makeSearchRequest(String baseUrl, String query) async {
    try {
      final url = '$baseUrl/search?q=${Uri.encodeComponent(query)}&force_refresh=false';
      print('🔍 Trying search request to: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(minutes: 10)); // Increased to 10 minutes for long-running searches
      
      print('📡 Search response status: ${response.statusCode}');
      print('📡 Search response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Search API Response: ${data.toString()}');
        return data;
      }
    } catch (e) {
      print('❌ Search request failed: $e');
    }
    return null;
  }

  // Product news API call
  static Future<Map<String, dynamic>?> getProductNews(String product) async {
    // For web, try to get a working URL first
    if (kIsWeb) {
      final workingUrl = await getWorkingUrl();
      if (workingUrl != null) {
        return await _makeProductNewsRequest(workingUrl, product);
      }
    }
    
    final List<String> possibleUrls = getBackendUrls();
    
    for (String baseUrl in possibleUrls) {
      try {
        print('🔍 Testing product news API at: $baseUrl');
        
        final result = await _makeProductNewsRequest(baseUrl, product);
        if (result != null) {
          return result;
        }
      } catch (e) {
        print('❌ Failed to connect to $baseUrl for product news: $e');
        continue; // Try next URL
      }
    }
    
    return null;
  }

  // Helper method to make product news request
  static Future<Map<String, dynamic>?> _makeProductNewsRequest(String baseUrl, String product) async {
    try {
      final url = '$baseUrl/product/news?product=${Uri.encodeComponent(product)}';
      print('🔍 Trying product news request to: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(minutes: 5)); // Increased timeout for AI processing
      
      print('📡 Product news response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Product news API Response: ${data.toString()}');
        return data;
      }
    } catch (e) {
      print('❌ Product news request failed: $e');
    }
    return null;
  }

  // Get similar products (repurchase suggestions) from product news API
  static Future<List<Map<String, dynamic>>> getSimilarProducts(String product) async {
    try {
      final newsData = await getProductNews(product);
      if (newsData != null && newsData['data'] != null) {
        final repurchaseData = newsData['data']['repurchase'] as List<dynamic>?;
        if (repurchaseData != null) {
          return repurchaseData.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      print('❌ Error getting similar products: $e');
    }
    
    // Return empty list if API fails
    return [];
  }

  // Get AI reports from product news API
  static Future<List<Map<String, dynamic>>> getAIReports(String product) async {
    try {
      final newsData = await getProductNews(product);
      if (newsData != null && newsData['data'] != null) {
        final reportsData = newsData['data']['reports'] as List<dynamic>?;
        if (reportsData != null) {
          return reportsData.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      print('❌ Error getting AI reports: $e');
    }
    
    // Return empty list if API fails
    return [];
  }

  // Get news from product news API
  static Future<List<Map<String, dynamic>>> getNews(String product) async {
    try {
      final newsData = await getProductNews(product);
      if (newsData != null && newsData['data'] != null) {
        final newsList = newsData['data']['news'] as List<dynamic>?;
        if (newsList != null) {
          return newsList.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      print('❌ Error getting news: $e');
    }
    
    // Return empty list if API fails
    return [];
  }

  // Debug method to test connectivity
  static Future<void> testConnectivity() async {
    print('🔍 Testing connectivity...');
    print('🌐 Platform: ${kIsWeb ? 'Web' : 'Mobile'}');
    
    final urls = getBackendUrls();
    print('🔗 URLs to test: $urls');
    
    for (String url in urls) {
      try {
        print('🔍 Testing: $url/test');
        final response = await http.get(
          Uri.parse('$url/test'),
          headers: {
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));
        
        print('✅ $url responded with status: ${response.statusCode}');
        if (response.statusCode == 200) {
          print('🎉 Working URL found: $url');
          return;
        }
      } catch (e) {
        print('❌ $url failed: $e');
        print('🔍 Error type: ${e.runtimeType}');
      }
    }
    
    print('❌ No working URLs found');
  }

  // Test connectivity specifically for mobile devices with ADB port forwarding
  static Future<void> testMobileConnectivity() async {
    print('📱 Testing mobile connectivity...');
    
    // Test ADB port forwarding first
    final adbUrls = ['http://127.0.0.1:5000', 'http://localhost:5000'];
    
    for (String url in adbUrls) {
      try {
        print('🔍 Testing ADB port forwarding: $url/test');
        final response = await http.get(
          Uri.parse('$url/test'),
          headers: {
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 3));
        
        if (response.statusCode == 200) {
          print('✅ ADB port forwarding working: $url');
          print('🎉 Mobile device can reach backend via USB!');
          return;
        }
      } catch (e) {
        print('❌ ADB port forwarding failed for $url: $e');
      }
    }
    
    print('⚠️ ADB port forwarding not working, trying network IPs...');
    await testConnectivity();
  }

  // Amazon deals API call
  static Future<Map<String, dynamic>?> getAmazonDeals() async {
    final workingUrl = await getWorkingUrl();
    if (workingUrl == null) {
      print('❌ No working URL found for Amazon deals');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$workingUrl/amazon/deals'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(minutes: 2));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        print('❌ Amazon deals API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Amazon deals request failed: $e');
      return null;
    }
  }

  // Flipkart deals API call
  static Future<Map<String, dynamic>?> getFlipkartDeals() async {
    final workingUrl = await getWorkingUrl();
    if (workingUrl == null) {
      print('❌ No working URL found for Flipkart deals');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$workingUrl/flipkart/deals'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(minutes: 2));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        print('❌ Flipkart deals API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Flipkart deals request failed: $e');
      return null;
    }
  }

  // Myntra deals API call
  static Future<Map<String, dynamic>?> getMyntraDeals() async {
    final workingUrl = await getWorkingUrl();
    if (workingUrl == null) {
      print('❌ No working URL found for Myntra deals');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$workingUrl/myntra/deals'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(minutes: 2));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        print('❌ Myntra deals API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Myntra deals request failed: $e');
      return null;
    }
  }

  // Unified deals API call for all platforms
  static Future<Map<String, dynamic>?> getUnifiedDeals(String platform) async {
    final workingUrl = await getWorkingUrl();
    if (workingUrl == null) {
      print('❌ No working URL found for unified deals');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$workingUrl/deals/unified?platform=$platform'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(minutes: 2));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        print('❌ Unified deals API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Unified deals request failed: $e');
      return null;
    }
  }
}
