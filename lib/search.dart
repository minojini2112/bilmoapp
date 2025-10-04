import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'best_deals_page.dart';

class SearchPage extends StatefulWidget {
  final String? searchQuery;
  
  const SearchPage({super.key, this.searchQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';
  bool _showSearchResults = false;
  
  final List<String> _recentSearches = [
    'iPhone 15 Pro Max',
    'Samsung Galaxy S24',
    'MacBook Air M2',
    'Flight tickets to Delhi',
    'Hotel rooms in Mumbai',
    'Designer sarees',
  ];

  final List<String> _popularSearches = [
    'Electronics',
    'Fashion',
    'Travel',
    'Hotels',
    'Flights',
    'Home & Kitchen',
    'Beauty',
    'Books',
  ];

  // Sample search results data
  final Map<String, List<SearchResult>> _searchResults = {
    'iphone': [
      SearchResult(title: 'iPhone 15 Pro Max 256GB', price: '₹1,19,900', originalPrice: '₹1,39,900', image: '📱', category: 'Electronics', platform: 'Amazon', saleStatus: 'Flash Sale', discountPercentage: 14, isOnSale: true),
      SearchResult(title: 'iPhone 15 Pro 128GB', price: '₹1,04,900', originalPrice: '₹1,19,900', image: '📱', category: 'Electronics', platform: 'Flipkart', saleStatus: 'Best Deal', discountPercentage: 13, isOnSale: true),
      SearchResult(title: 'iPhone 14 Pro Max', price: '₹89,900', originalPrice: '₹1,09,900', image: '📱', category: 'Electronics', platform: 'Reliance Digital', saleStatus: 'Clearance', discountPercentage: 18, isOnSale: true),
      SearchResult(title: 'iPhone 13 Pro', price: '₹69,900', originalPrice: '₹89,900', image: '📱', category: 'Electronics', platform: 'Croma', saleStatus: 'Limited Time', discountPercentage: 22, isOnSale: true),
      SearchResult(title: 'iPhone 12', price: '₹49,900', originalPrice: '₹69,900', image: '📱', category: 'Electronics', platform: 'Vijay Sales', saleStatus: 'End of Season', discountPercentage: 29, isOnSale: true),
      SearchResult(title: 'iPhone SE 3rd Gen', price: '₹39,900', originalPrice: '₹49,900', image: '📱', category: 'Electronics', platform: 'Amazon', saleStatus: 'Daily Deal', discountPercentage: 20, isOnSale: true),
    ],
    'samsung': [
      SearchResult(title: 'Samsung Galaxy S24 Ultra', price: '₹1,24,999', originalPrice: '₹1,34,999', image: '📱', category: 'Electronics', platform: 'Flipkart', saleStatus: 'Mega Sale', discountPercentage: 7, isOnSale: true),
      SearchResult(title: 'Samsung Galaxy S24', price: '₹79,999', originalPrice: '₹89,999', image: '📱', category: 'Electronics', platform: 'Amazon', saleStatus: 'Prime Deal', discountPercentage: 11, isOnSale: true),
      SearchResult(title: 'Samsung Galaxy Z Fold 5', price: '₹1,64,999', originalPrice: '₹1,74,999', image: '📱', category: 'Electronics', platform: 'Reliance Digital', saleStatus: 'Exclusive', discountPercentage: 6, isOnSale: true),
      SearchResult(title: 'Samsung Galaxy A54', price: '₹34,999', originalPrice: '₹39,999', image: '📱', category: 'Electronics', platform: 'Croma', saleStatus: 'Weekend Sale', discountPercentage: 13, isOnSale: true),
      SearchResult(title: 'Samsung Galaxy Note 20', price: '₹59,999', originalPrice: '₹79,999', image: '📱', category: 'Electronics', platform: 'Vijay Sales', saleStatus: 'Clearance', discountPercentage: 25, isOnSale: true),
      SearchResult(title: 'Samsung Galaxy Watch 6', price: '₹24,999', originalPrice: '₹29,999', image: '⌚', category: 'Electronics', platform: 'Amazon', saleStatus: 'Best Price', discountPercentage: 17, isOnSale: true),
    ],
    'flight': [
      SearchResult(title: 'Mumbai to Delhi Flight', price: '₹4,500', originalPrice: '₹6,500', image: '✈️', category: 'Travel', platform: 'MakeMyTrip', saleStatus: 'Early Bird', discountPercentage: 31, isOnSale: true),
      SearchResult(title: 'Bangalore to Goa Flight', price: '₹3,200', originalPrice: '₹4,800', image: '✈️', category: 'Travel', platform: 'Yatra', saleStatus: 'Weekend Special', discountPercentage: 33, isOnSale: true),
      SearchResult(title: 'Chennai to Mumbai Flight', price: '₹5,800', originalPrice: '₹7,200', image: '✈️', category: 'Travel', platform: 'Goibibo', saleStatus: 'Flash Sale', discountPercentage: 19, isOnSale: true),
      SearchResult(title: 'Delhi to Bangalore Flight', price: '₹6,200', originalPrice: '₹8,200', image: '✈️', category: 'Travel', platform: 'Cleartrip', saleStatus: 'Best Deal', discountPercentage: 24, isOnSale: true),
      SearchResult(title: 'Mumbai to Goa Flight', price: '₹2,800', originalPrice: '₹4,200', image: '✈️', category: 'Travel', platform: 'EaseMyTrip', saleStatus: 'Limited Time', discountPercentage: 33, isOnSale: true),
      SearchResult(title: 'Kolkata to Delhi Flight', price: '₹5,500', originalPrice: '₹7,500', image: '✈️', category: 'Travel', platform: 'MakeMyTrip', saleStatus: 'Prime Deal', discountPercentage: 27, isOnSale: true),
    ],
    'hotel': [
      SearchResult(title: 'Taj Palace Hotel - Mumbai', price: '₹12,000/night', originalPrice: '₹15,000/night', image: '🏨', category: 'Hotels', platform: 'Booking.com', saleStatus: 'Luxury Deal', discountPercentage: 20, isOnSale: true),
      SearchResult(title: 'Oberoi Hotel - Delhi', price: '₹15,000/night', originalPrice: '₹18,000/night', image: '🏨', category: 'Hotels', platform: 'Agoda', saleStatus: 'Premium Offer', discountPercentage: 17, isOnSale: true),
      SearchResult(title: 'ITC Maratha - Mumbai', price: '₹8,500/night', originalPrice: '₹11,000/night', image: '🏨', category: 'Hotels', platform: 'MakeMyTrip', saleStatus: 'Weekend Special', discountPercentage: 23, isOnSale: true),
      SearchResult(title: 'Leela Palace - Bangalore', price: '₹9,500/night', originalPrice: '₹12,000/night', image: '🏨', category: 'Hotels', platform: 'Yatra', saleStatus: 'Best Price', discountPercentage: 21, isOnSale: true),
      SearchResult(title: 'JW Marriott - Delhi', price: '₹11,000/night', originalPrice: '₹14,000/night', image: '🏨', category: 'Hotels', platform: 'Goibibo', saleStatus: 'Flash Sale', discountPercentage: 21, isOnSale: true),
      SearchResult(title: 'Hyatt Regency - Mumbai', price: '₹7,500/night', originalPrice: '₹10,000/night', image: '🏨', category: 'Hotels', platform: 'Cleartrip', saleStatus: 'Limited Time', discountPercentage: 25, isOnSale: true),
    ],
    'dress': [
      SearchResult(title: 'Designer Saree Collection', price: '₹8,999', originalPrice: '₹12,999', image: '👗', category: 'Fashion', platform: 'Myntra', saleStatus: 'Festival Sale', discountPercentage: 31, isOnSale: true),
      SearchResult(title: 'Cocktail Dress - Zara', price: '₹2,999', originalPrice: '₹4,999', image: '👗', category: 'Fashion', platform: 'Ajio', saleStatus: 'End of Season', discountPercentage: 40, isOnSale: true),
      SearchResult(title: 'Wedding Lehenga', price: '₹25,000', originalPrice: '₹35,000', image: '👗', category: 'Fashion', platform: 'Flipkart', saleStatus: 'Wedding Special', discountPercentage: 29, isOnSale: true),
      SearchResult(title: 'Party Wear Gown', price: '₹4,500', originalPrice: '₹6,500', image: '👗', category: 'Fashion', platform: 'Amazon', saleStatus: 'Party Collection', discountPercentage: 31, isOnSale: true),
      SearchResult(title: 'Casual Kurti Set', price: '₹1,299', originalPrice: '₹2,299', image: '👗', category: 'Fashion', platform: 'Voonik', saleStatus: 'Daily Deal', discountPercentage: 43, isOnSale: true),
      SearchResult(title: 'Formal Business Suit', price: '₹5,999', originalPrice: '₹8,999', image: '👔', category: 'Fashion', platform: 'Lifestyle', saleStatus: 'Corporate Sale', discountPercentage: 33, isOnSale: true),
    ],
    'laptop': [
      SearchResult(title: 'MacBook Air M2 13-inch', price: '₹89,900', originalPrice: '₹1,09,900', image: '💻', category: 'Electronics', platform: 'Apple Store', saleStatus: 'Student Offer', discountPercentage: 18, isOnSale: true),
      SearchResult(title: 'MacBook Pro M3 14-inch', price: '₹1,49,900', originalPrice: '₹1,69,900', image: '💻', category: 'Electronics', platform: 'Amazon', saleStatus: 'Prime Deal', discountPercentage: 12, isOnSale: true),
      SearchResult(title: 'Dell XPS 13', price: '₹89,999', originalPrice: '₹1,09,999', image: '💻', category: 'Electronics', platform: 'Flipkart', saleStatus: 'Tech Sale', discountPercentage: 18, isOnSale: true),
      SearchResult(title: 'HP Pavilion 15', price: '₹54,999', originalPrice: '₹69,999', image: '💻', category: 'Electronics', platform: 'Croma', saleStatus: 'Weekend Special', discountPercentage: 21, isOnSale: true),
      SearchResult(title: 'Lenovo ThinkPad X1', price: '₹1,19,999', originalPrice: '₹1,39,999', image: '💻', category: 'Electronics', platform: 'Reliance Digital', saleStatus: 'Business Deal', discountPercentage: 14, isOnSale: true),
      SearchResult(title: 'ASUS ROG Gaming Laptop', price: '₹79,999', originalPrice: '₹99,999', image: '💻', category: 'Electronics', platform: 'Vijay Sales', saleStatus: 'Gaming Special', discountPercentage: 20, isOnSale: true),
    ],
    'headphone': [
      SearchResult(title: 'Sony WH-1000XM5', price: '₹24,990', originalPrice: '₹29,990', image: '🎧', category: 'Electronics', platform: 'Amazon', saleStatus: 'Audio Sale', discountPercentage: 17, isOnSale: true),
      SearchResult(title: 'AirPods Pro 2nd Gen', price: '₹24,900', originalPrice: '₹29,900', image: '🎧', category: 'Electronics', platform: 'Apple Store', saleStatus: 'Apple Deal', discountPercentage: 17, isOnSale: true),
      SearchResult(title: 'Bose QuietComfort 45', price: '₹29,900', originalPrice: '₹34,900', image: '🎧', category: 'Electronics', platform: 'Flipkart', saleStatus: 'Premium Audio', discountPercentage: 14, isOnSale: true),
      SearchResult(title: 'Sennheiser HD 660S', price: '₹34,999', originalPrice: '₹39,999', image: '🎧', category: 'Electronics', platform: 'Croma', saleStatus: 'Pro Audio', discountPercentage: 13, isOnSale: true),
      SearchResult(title: 'JBL Live Pro 2', price: '₹12,999', originalPrice: '₹16,999', image: '🎧', category: 'Electronics', platform: 'Reliance Digital', saleStatus: 'Music Special', discountPercentage: 24, isOnSale: true),
      SearchResult(title: 'Beats Studio3 Wireless', price: '₹19,999', originalPrice: '₹24,999', image: '🎧', category: 'Electronics', platform: 'Vijay Sales', saleStatus: 'Beats Deal', discountPercentage: 20, isOnSale: true),
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadSearchQuery();
  }

  Future<void> _loadSearchQuery() async {
    // First check if searchQuery was passed as parameter
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      setState(() {
        _searchController.text = widget.searchQuery!;
        _currentSearchQuery = widget.searchQuery!;
        _showSearchResults = true;
      });
      return;
    }
    
    // Try to load from SharedPreferences as fallback
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedQuery = prefs.getString('search_query') ?? '';
      if (savedQuery.isNotEmpty) {
        setState(() {
          _searchController.text = savedQuery;
          _currentSearchQuery = savedQuery;
          _showSearchResults = true;
        });
      }
    } catch (e) {
      // SharedPreferences not available (e.g., in web mode)
      print('SharedPreferences not available: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _showSearchResults ? _buildFloatingMenu() : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D1B69), // Deep purple
              Color(0xFF1A1A2E), // Dark blue
              Colors.black, // Black at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with BILMO branding
              _buildHeader(),
              
              // Main content
              Expanded(
                child: _showSearchResults ? _buildSearchResults() : _buildSearchSuggestions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button and BILMO Logo
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ai',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'BILMO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // Wishlist and Cart Icons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.white, size: 24),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WishlistPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search for products, deals, and more...',
                hintStyle: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.search, color: Colors.white, size: 20),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _performSearch(value);
                }
              },
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            const Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) => _buildSearchChip(search)).toList(),
            ),
            const SizedBox(height: 30),
          ],
          
          // Popular Searches
          const Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((search) => _buildSearchChip(search)).toList(),
          ),
          
          const SizedBox(height: 30),
          
          // Search Suggestions
          const Text(
            'Search Suggestions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildSuggestionCard('🔍', 'Find the best deals', 'Discover amazing offers on your favorite products'),
          const SizedBox(height: 12),
          _buildSuggestionCard('✈️', 'Book flights', 'Search and compare flight prices'),
          const SizedBox(height: 12),
          _buildSuggestionCard('🏨', 'Hotel bookings', 'Find the perfect accommodation'),
          const SizedBox(height: 12),
          _buildSuggestionCard('👗', 'Fashion & Style', 'Shop the latest fashion trends'),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _getSearchResults(_currentSearchQuery);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search for products, deals, and more...',
              hintStyle: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 20),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.white70),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _showSearchResults = false;
                    _currentSearchQuery = '';
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _performSearch(value);
              }
            },
          ),
        ),
        
        // Search Results Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Search Results for "$_currentSearchQuery"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Search Results Grid - 2x3 layout as per wireframe
        Expanded(
          child: results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No results found for "$_currentSearchQuery"',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: results.length > 6 ? 6 : results.length, // Limit to 6 items for 2x3 grid
                    itemBuilder: (context, index) {
                      final result = results[index];
                      return _buildSearchResultCard(result);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchResultCard(SearchResult result) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with platform and sale status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Platform badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result.platform,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Sale status badge
                if (result.isOnSale)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      result.saleStatus,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Image container
          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
            ),
            child: Center(
              child: Text(
                result.image,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          
          // Content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title and category
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.title,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.category,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  
                  // Price section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current price
                      Text(
                        result.price,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      // Original price and discount
                      if (result.isOnSale && result.originalPrice.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              result.originalPrice,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white60,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${result.discountPercentage}% OFF',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String text) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        _performSearch(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(String emoji, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white70,
            size: 16,
          ),
        ],
      ),
    );
  }

  List<SearchResult> _getSearchResults(String query) {
    final lowercaseQuery = query.toLowerCase().trim();
    
    // Check for exact matches first
    if (_searchResults.containsKey(lowercaseQuery)) {
      return _searchResults[lowercaseQuery]!;
    }
    
    // Check for partial matches and related terms
    List<SearchResult> results = [];
    Set<String> addedTitles = {}; // To avoid duplicates
    
    for (final entry in _searchResults.entries) {
      if (entry.key.contains(lowercaseQuery) || 
          lowercaseQuery.contains(entry.key) ||
          _isRelatedSearch(lowercaseQuery, entry.key)) {
        for (final result in entry.value) {
          if (!addedTitles.contains(result.title)) {
            results.add(result);
            addedTitles.add(result.title);
          }
        }
      }
    }
    
    // If no matches found, return some default results
    if (results.isEmpty) {
      return [
        SearchResult(title: 'No results found', price: '', originalPrice: '', image: '❌', category: '', platform: '', saleStatus: '', discountPercentage: 0, isOnSale: false),
      ];
    }
    
    return results;
  }

  bool _isRelatedSearch(String query, String key) {
    // Define related search terms
    final Map<String, List<String>> relatedTerms = {
      'phone': ['iphone', 'samsung', 'mobile', 'smartphone'],
      'mobile': ['iphone', 'samsung', 'phone', 'smartphone'],
      'smartphone': ['iphone', 'samsung', 'phone', 'mobile'],
      'travel': ['flight', 'hotel', 'trip'],
      'accommodation': ['hotel', 'stay', 'booking'],
      'clothes': ['dress', 'fashion', 'wear', 'clothing'],
      'computer': ['laptop', 'macbook', 'dell', 'hp'],
      'audio': ['headphone', 'earphone', 'speaker', 'music'],
    };
    
    for (final entry in relatedTerms.entries) {
      if (entry.key.contains(query) || query.contains(entry.key)) {
        return entry.value.contains(key);
      }
    }
    
    return false;
  }

  void _performSearch(String query) {
    setState(() {
      _currentSearchQuery = query;
      _showSearchResults = true;
    });
    
    // Add to recent searches if not already present
    if (!_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 6) {
          _recentSearches.removeLast();
        }
      });
    }
    
    // Try to save to SharedPreferences
    _saveSearchQuery(query);
  }

  Future<void> _saveSearchQuery(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('search_query', query);
    } catch (e) {
      // SharedPreferences not available (e.g., in web mode)
      print('Could not save search query: $e');
    }
  }

  Widget _buildFloatingMenu() {
    return Container(
      height: 80,
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFloatingMenuBox('Best Deals', Icons.local_offer, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BestDealsPage()),
            );
          }),
          _buildFloatingMenuBox('AI Report', Icons.analytics, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AIReportPage()),
            );
          }),
          _buildFloatingMenuBox('News', Icons.newspaper, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('News section coming soon!'),
                backgroundColor: Colors.red,
              ),
            );
          }),
          _buildFloatingMenuBox('Reels', Icons.video_library, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reels section coming soon!'),
                backgroundColor: Colors.red,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFloatingMenuBox(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 65,
        height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D1B69), // Deep purple
              Colors.black, // Black at bottom
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Search Result Data Model
class SearchResult {
  final String title;
  final String price;
  final String originalPrice;
  final String image;
  final String category;
  final String platform;
  final String saleStatus;
  final int discountPercentage;
  final bool isOnSale;

  SearchResult({
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.image,
    required this.category,
    required this.platform,
    required this.saleStatus,
    required this.discountPercentage,
    required this.isOnSale,
  });
}