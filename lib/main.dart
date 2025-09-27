import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'search.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deals App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _chatController = TextEditingController();

  // Sample data for deals - Exact products with Indian Rupee pricing
  final List<DealItem> _deals = [
    DealItem(title: "iPhone 15 Pro Max 256GB", price: "₹1,19,900", originalPrice: "₹1,39,900", image: "📱"),
    DealItem(title: "Samsung Galaxy S24 Ultra", price: "₹1,24,999", originalPrice: "₹1,34,999", image: "📱"),
    DealItem(title: "MacBook Air M2 13-inch", price: "₹89,900", originalPrice: "₹1,09,900", image: "💻"),
    DealItem(title: "Sony WH-1000XM5 Headphones", price: "₹24,990", originalPrice: "₹29,990", image: "🎧"),
    DealItem(title: "Apple Watch Series 9", price: "₹41,900", originalPrice: "₹45,900", image: "⌚"),
  ];

  // Sample data for featured items - Exact products
  final List<FeaturedItem> _featuredItems = [
    FeaturedItem(title: "Dyson V15 Detect Vacuum", description: "₹54,900", image: "🧹"),
    FeaturedItem(title: "Nintendo Switch OLED", description: "₹32,999", image: "🎮"),
    FeaturedItem(title: "Instant Pot Duo 7-in-1", description: "₹12,999", image: "🍲"),
    FeaturedItem(title: "AirPods Pro 2nd Gen", description: "₹24,900", image: "🎧"),
  ];

  // Sample data for e-commerce products - Organized by categories
  final Map<String, List<EcommerceProduct>> _productsByCategory = {
    "Flight Tickets": [
      EcommerceProduct(category: "Flight Tickets", title: "Mumbai to Delhi", price: "₹4,500", image: "✈️"),
      EcommerceProduct(category: "Flight Tickets", title: "Bangalore to Goa", price: "₹3,200", image: "✈️"),
      EcommerceProduct(category: "Flight Tickets", title: "Chennai to Mumbai", price: "₹5,800", image: "✈️"),
      EcommerceProduct(category: "Flight Tickets", title: "Delhi to Bangalore", price: "₹6,200", image: "✈️"),
      EcommerceProduct(category: "Flight Tickets", title: "Mumbai to Goa", price: "₹2,800", image: "✈️"),
    ],
    "Hotel Rooms": [
      EcommerceProduct(category: "Hotel Rooms", title: "Taj Palace - Mumbai", price: "₹12,000/night", image: "🏨"),
      EcommerceProduct(category: "Hotel Rooms", title: "Oberoi - Delhi", price: "₹15,000/night", image: "🏨"),
      EcommerceProduct(category: "Hotel Rooms", title: "ITC Maratha - Mumbai", price: "₹8,500/night", image: "🏨"),
      EcommerceProduct(category: "Hotel Rooms", title: "Leela Palace - Bangalore", price: "₹9,500/night", image: "🏨"),
      EcommerceProduct(category: "Hotel Rooms", title: "JW Marriott - Delhi", price: "₹11,000/night", image: "🏨"),
    ],
    "Fashion Dresses": [
      EcommerceProduct(category: "Fashion Dresses", title: "Designer Saree", price: "₹8,999", image: "👗"),
      EcommerceProduct(category: "Fashion Dresses", title: "Cocktail Dress - Zara", price: "₹2,999", image: "👗"),
      EcommerceProduct(category: "Fashion Dresses", title: "Wedding Lehenga", price: "₹25,000", image: "👗"),
      EcommerceProduct(category: "Fashion Dresses", title: "Party Wear Gown", price: "₹4,500", image: "👗"),
      EcommerceProduct(category: "Fashion Dresses", title: "Casual Kurti Set", price: "₹1,299", image: "👗"),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Deals',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Highly Demanded Deals Section
            _buildDealsSection(),
            
            const SizedBox(height: 20),
            
            // Chat Box Section - Centered
            _buildChatBox(),
            
            const SizedBox(height: 30),
            
            // Featured For You Section
            _buildFeaturedSection(),
            
            const SizedBox(height: 20),
            
            // E-commerce Products Section
            _buildEcommerceSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDealsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Highly Demanded Deals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _deals.length,
              itemBuilder: (context, index) {
                final deal = _deals[index];
                return Container(
                  width: 170,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 110,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[50]!, Colors.blue[100]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Center(
                          child: Text(
                            deal.image,
                            style: const TextStyle(fontSize: 45),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  deal.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    deal.price,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    deal.originalPrice,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _chatController,
        decoration: InputDecoration(
          hintText: 'ASK ME ANYTHING',
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.search, color: Colors.blue, size: 24),
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () async {
                // Store search query in local storage and navigate to search page
                if (_chatController.text.isNotEmpty) {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('search_query', _chatController.text);
                  } catch (e) {
                    // Fallback for web or if SharedPreferences fails
                    print('SharedPreferences not available: $e');
                  }
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(searchQuery: _chatController.text),
                  ),
                );
              },
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onSubmitted: (value) async {
          if (value.isNotEmpty) {
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('search_query', value);
            } catch (e) {
              // Fallback for web or if SharedPreferences fails
              print('SharedPreferences not available: $e');
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(searchQuery: value),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FEATURED FOR YOU',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _featuredItems.length,
              itemBuilder: (context, index) {
                final item = _featuredItems[index];
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.image,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcommerceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'E-commerce Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          // Create a row for each category
          ..._productsByCategory.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) {
                      final product = entry.value[index];
                      return Container(
                        width: 170,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey[50]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 110,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue[50]!, Colors.blue[100]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              child: Center(
                                child: Text(
                                  product.image,
                                  style: const TextStyle(fontSize: 45),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      product.price,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}

// Data models
class DealItem {
  final String title;
  final String price;
  final String originalPrice;
  final String image;

  DealItem({
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.image,
  });
}

class FeaturedItem {
  final String title;
  final String description;
  final String image;

  FeaturedItem({
    required this.title,
    required this.description,
    required this.image,
  });
}

class EcommerceProduct {
  final String category;
  final String title;
  final String price;
  final String image;

  EcommerceProduct({
    required this.category,
    required this.title,
    required this.price,
    required this.image,
  });
}
