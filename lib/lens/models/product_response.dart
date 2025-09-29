import 'dart:convert';

class ProductResponse {
  final String productName;
  final String category;
  final String description;
  final List<String> keyFeatures;
  final String estimatedPrice;
  final List<String> brands;
  final List<SimilarProduct> similarProducts;
  final List<String> searchSuggestions;
  final String confidence;

  ProductResponse({
    required this.productName,
    required this.category,
    required this.description,
    required this.keyFeatures,
    required this.estimatedPrice,
    required this.brands,
    required this.similarProducts,
    required this.searchSuggestions,
    required this.confidence,
  });

  factory ProductResponse.fromJson(String jsonString) {
    try {
      // Clean the JSON string (remove markdown formatting if present)
      String cleanJson = jsonString.trim();
      if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(7);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      final Map<String, dynamic> json = jsonDecode(cleanJson);
      
      return ProductResponse(
        productName: json['productName'] ?? 'Unknown Product',
        category: json['category'] ?? 'Unknown Category',
        description: json['description'] ?? 'No description available',
        keyFeatures: List<String>.from(json['keyFeatures'] ?? []),
        estimatedPrice: json['estimatedPrice'] ?? 'Price not available',
        brands: List<String>.from(json['brands'] ?? []),
        similarProducts: (json['similarProducts'] as List<dynamic>?)
                ?.map((item) => SimilarProduct.fromJson(item))
                .toList() ??
            [],
        searchSuggestions: List<String>.from(json['searchSuggestions'] ?? []),
        confidence: json['confidence'] ?? 'Unknown',
      );
    } catch (e) {
      print('Error parsing JSON: $e');
      print('JSON String: $jsonString');
      return ProductResponse.createFallback('Failed to parse product information');
    }
  }

  factory ProductResponse.createFallback(String errorMessage) {
    return ProductResponse(
      productName: 'Analysis Failed',
      category: 'Unknown',
      description: errorMessage,
      keyFeatures: [],
      estimatedPrice: 'N/A',
      brands: [],
      similarProducts: [],
      searchSuggestions: [],
      confidence: 'Low',
    );
  }
}

class SimilarProduct {
  final String name;
  final String description;
  final String estimatedPrice;
  final String marketplace;

  SimilarProduct({
    required this.name,
    required this.description,
    required this.estimatedPrice,
    required this.marketplace,
  });

  factory SimilarProduct.fromJson(Map<String, dynamic> json) {
    return SimilarProduct(
      name: json['name'] ?? 'Unknown Product',
      description: json['description'] ?? 'No description',
      estimatedPrice: json['estimatedPrice'] ?? 'Price not available',
      marketplace: json['marketplace'] ?? 'Unknown marketplace',
    );
  }
}
