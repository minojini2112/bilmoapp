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
      backgroundColor: const Color(0xFF1A1A2E),
      drawer: _buildDrawer(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8B0000), // Dark red
              Color(0xFF4B0082), // Indigo
              Color(0xFF1A1A2E), // Dark blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              // Content
              Expanded(
                child: SingleChildScrollView(
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
                                color: Colors.white,
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
                                color: Colors.white70,
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
                          style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.white70),
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
                                          Expanded(
                                            child: Text(
                                              feature,
                                              style: const TextStyle(color: Colors.white70),
                                            ),
                                          ),
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
              ),
            ],
          ),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 24),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.analytics, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          const Text(
            'Analysis Results',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A2E),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8B0000), // Dark red
              Color(0xFF4B0082), // Indigo
              Color(0xFF1A1A2E), // Dark blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ai',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'BILMO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem('DASHBOARD', Icons.dashboard, () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/');
                    }),
                    _buildDrawerItem('BEST DEALS', Icons.local_offer, () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/best-deals');
                    }),
                    _buildDrawerItem('AI REPORT', Icons.analytics, () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/ai-report');
                    }),
                    _buildDrawerItem('BOOK TICKETS', Icons.confirmation_number, () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/book-tickets');
                    }),
                    _buildDrawerItem('HOTEL BOOKINGS', Icons.hotel, () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/hotel-bookings');
                    }),
                    _buildDrawerItem('BILMO LENS', Icons.camera_alt, () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/camera');
                    }),
                    _buildDrawerItem('CART', Icons.shopping_cart, () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/cart');
                    }),
                    _buildDrawerItem('WISHLIST', Icons.favorite, () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/wishlist');
                    }),
                    _buildDrawerItem('ABOUT US', Icons.info, () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/about-us');
                    }),
                    _buildDrawerItem('PRICING', Icons.attach_money, () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/pricing');
                    }),
                    _buildDrawerItem('CONTACT US', Icons.contact_mail, () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/contact-us');
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
