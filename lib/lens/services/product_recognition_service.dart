import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/product_response.dart';

class ProductRecognitionService {
  static const String _apiKey = 'AIzaSyBfmydUw5R58UrM95tPhTWl6Eki9EJ1W6Y'; // Your Gemini API key
  static const String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  Future<ProductResponse> analyzeProduct(File imageFile) async {
    try {
      // Read image as bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Convert image to base64 (equivalent to base64 -w0 in shell script)
      final String base64Image = base64Encode(imageBytes);
      
      // Create the prompt for product recognition
      const prompt = '''
      Analyze this product image and provide the following information in JSON format:
      
      {
        "productName": "Main product name/title",
        "category": "Product category (e.g., Electronics, Clothing, etc.)",
        "description": "Brief description of the product",
        "keyFeatures": ["feature1", "feature2", "feature3"],
        "estimatedPrice": "Estimated price range in INR (₹)",
        "brands": ["possible brand names"],
        "similarProducts": [
          {
            "name": "Similar product name",
            "description": "Brief description",
            "estimatedPrice": "Price range in INR (₹)",
            "marketplace": "Where to find (Amazon, eBay, etc.)"
          }
        ],
        "searchSuggestions": ["keyword1", "keyword2", "keyword3"],
        "confidence": "High/Medium/Low confidence in identification"
      }
      
      Focus on identifying the main product, its key characteristics, and suggest similar products that might be available on major e-commerce platforms like Amazon India, Flipkart, Myntra, Snapdeal, etc. Provide prices in Indian Rupees (₹). If you're not sure about the exact product, provide the closest matches and indicate lower confidence.
      ''';

      // Create the request body (equivalent to the curl -d payload)
      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image
                }
              },
              {
                "text": prompt
              }
            ]
          }
        ]
      };

      // Make HTTP POST request (equivalent to curl command)
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'x-goog-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        throw Exception('API request failed with status: ${response.statusCode}, body: ${response.body}');
      }

      // Parse the response
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      // Extract the text content from the response
      String? responseText;
      if (responseData['candidates'] != null && 
          responseData['candidates'].isNotEmpty &&
          responseData['candidates'][0]['content'] != null &&
          responseData['candidates'][0]['content']['parts'] != null &&
          responseData['candidates'][0]['content']['parts'].isNotEmpty) {
        responseText = responseData['candidates'][0]['content']['parts'][0]['text'];
      }

      if (responseText == null || responseText.isEmpty) {
        throw Exception('No response received from Gemini API');
      }

      // Parse the JSON response
      return ProductResponse.fromJson(responseText);
      
    } catch (e) {
      print('Error in product analysis: $e');
      // Return a fallback response in case of error
      return ProductResponse.createFallback('Error analyzing product: ${e.toString()}');
    }
  }
}
