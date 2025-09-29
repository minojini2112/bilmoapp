import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product_response.dart';

class ProductResultsScreen extends StatelessWidget {
  final ProductResponse productResponse;
  final File imageFile;

  const ProductResultsScreen({
    Key? key,
    required this.productResponse,
    required this.imageFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilmo Lens - Analysis Results'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image display
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  imageFile,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Product name and confidence
            Row(
              children: [
                Expanded(
                  child: Text(
                    productResponse.productName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(productResponse.confidence),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    productResponse.confidence,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Category and price
            Row(
              children: [
                Icon(Icons.category, color: Colors.blue[600], size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    productResponse.category,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.currency_rupee, color: Colors.green[600], size: 18),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    productResponse.estimatedPrice,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Description
            _buildSection(
              'Description',
              Icons.description,
              Text(
                productResponse.description,
                style: const TextStyle(fontSize: 15, height: 1.4),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Key Features
            if (productResponse.keyFeatures.isNotEmpty)
              _buildSection(
                'Key Features',
                Icons.star,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: productResponse.keyFeatures
                      .map((feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, 
                                     color: Colors.green[600], size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(feature)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            
            // Brands
            if (productResponse.brands.isNotEmpty)
              _buildSection(
                'Possible Brands',
                Icons.business,
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: productResponse.brands
                      .map((brand) => Chip(
                            label: Text(brand),
                            backgroundColor: Colors.blue[50],
                            labelStyle: TextStyle(color: Colors.blue[700]),
                          ))
                      .toList(),
                ),
              ),
            
            // Similar Products
            if (productResponse.similarProducts.isNotEmpty)
              _buildSection(
                'Similar Products Available',
                Icons.shopping_cart,
                Column(
                  children: productResponse.similarProducts
                      .map((product) => _buildSimilarProductCard(product))
                      .toList(),
                ),
              ),
            
            // Search Suggestions
            if (productResponse.searchSuggestions.isNotEmpty)
              _buildSection(
                'Search Suggestions',
                Icons.search,
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: productResponse.searchSuggestions
                      .map((suggestion) => ActionChip(
                            label: Text(suggestion),
                            onPressed: () {
                              // You can implement search functionality here
                              _showSearchDialog(context, suggestion);
                            },
                            backgroundColor: Colors.orange[50],
                            labelStyle: TextStyle(color: Colors.orange[700]),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(icon, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildSimilarProductCard(SimilarProduct product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name and marketplace in a flexible row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.marketplace,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description with proper wrapping
            Text(
              product.description,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.3,
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Price and button in a flexible row
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.estimatedPrice,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Implement search/redirect functionality
                    _showSearchDialog(null, product.name);
                  },
                  icon: const Icon(Icons.search, size: 14),
                  label: const Text('Find', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(String confidence) {
    switch (confidence.toLowerCase()) {
      case 'high':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showSearchDialog(BuildContext? context, String searchTerm) {
    if (context == null) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Product'),
          content: Text('Would you like to search for "$searchTerm"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Search'),
              onPressed: () {
                Navigator.of(context).pop();
                // Here you can implement actual search functionality
                // For example, open a web browser or navigate to a search screen
              },
            ),
          ],
        );
      },
    );
  }
}
