import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      SearchResult(title: 'iPhone 15 Pro Max 256GB', price: '₹1,19,900', originalPrice: '₹1,39,900', image: '📱', category: 'Electronics'),
      SearchResult(title: 'iPhone 15 Pro 128GB', price: '₹1,04,900', originalPrice: '₹1,19,900', image: '📱', category: 'Electronics'),
      SearchResult(title: 'iPhone 14 Pro Max', price: '₹89,900', originalPrice: '₹1,09,900', image: '📱', category: 'Electronics'),
      SearchResult(title: 'iPhone 13 Pro', price: '₹69,900', originalPrice: '₹89,900', image: '📱', category: 'Electronics'),
      SearchResult(title: 'iPhone 12', price: '₹49,900', originalPrice: '₹69,900', image: '📱', category: 'Electronics'),
      SearchResult(title: 'iPhone SE 3rd Gen', price: '₹39,900', originalPrice: '₹49,900', image: '📱', category: 'Electronics'),
    ],
    'samsung': [
      SearchResult(title: 'Samsung Galaxy S24 Ultra', price: '₹1,24,999', originalPrice: '₹1,34,999', image: '📱', category: 'Electronics'),
      SearchResult(title: 'Samsung Galaxy S24', price: '₹79,999', originalPrice: '₹89,999', image: '📱', category: 'Electronics'),
      SearchResult(title: 'Samsung Galaxy Z Fold 5', price: '₹1,64,999', originalPrice: '₹1,74,999', image: '📱', category: 'Electronics'),
      SearchResult(title: 'Samsung Galaxy A54', price: '₹34,999', originalPrice: '₹39,999', image: '📱', category: 'Electronics'),
      SearchResult(title: 'Samsung Galaxy Note 20', price: '₹59,999', originalPrice: '₹79,999', image: '📱', category: 'Electronics'),
      SearchResult(title: 'Samsung Galaxy Watch 6', price: '₹24,999', originalPrice: '₹29,999', image: '⌚', category: 'Electronics'),
    ],
    'flight': [
      SearchResult(title: 'Mumbai to Delhi Flight', price: '₹4,500', originalPrice: '₹6,500', image: '✈️', category: 'Travel'),
      SearchResult(title: 'Bangalore to Goa Flight', price: '₹3,200', originalPrice: '₹4,800', image: '✈️', category: 'Travel'),
      SearchResult(title: 'Chennai to Mumbai Flight', price: '₹5,800', originalPrice: '₹7,200', image: '✈️', category: 'Travel'),
      SearchResult(title: 'Delhi to Bangalore Flight', price: '₹6,200', originalPrice: '₹8,200', image: '✈️', category: 'Travel'),
      SearchResult(title: 'Mumbai to Goa Flight', price: '₹2,800', originalPrice: '₹4,200', image: '✈️', category: 'Travel'),
      SearchResult(title: 'Kolkata to Delhi Flight', price: '₹5,500', originalPrice: '₹7,500', image: '✈️', category: 'Travel'),
    ],
    'hotel': [
      SearchResult(title: 'Taj Palace Hotel - Mumbai', price: '₹12,000/night', originalPrice: '₹15,000/night', image: '🏨', category: 'Hotels'),
      SearchResult(title: 'Oberoi Hotel - Delhi', price: '₹15,000/night', originalPrice: '₹18,000/night', image: '🏨', category: 'Hotels'),
      SearchResult(title: 'ITC Maratha - Mumbai', price: '₹8,500/night', originalPrice: '₹11,000/night', image: '🏨', category: 'Hotels'),
      SearchResult(title: 'Leela Palace - Bangalore', price: '₹9,500/night', originalPrice: '₹12,000/night', image: '🏨', category: 'Hotels'),
      SearchResult(title: 'JW Marriott - Delhi', price: '₹11,000/night', originalPrice: '₹14,000/night', image: '🏨', category: 'Hotels'),
      SearchResult(title: 'Hyatt Regency - Mumbai', price: '₹7,500/night', originalPrice: '₹10,000/night', image: '🏨', category: 'Hotels'),
    ],
    'dress': [
      SearchResult(title: 'Designer Saree Collection', price: '₹8,999', originalPrice: '₹12,999', image: '👗', category: 'Fashion'),
      SearchResult(title: 'Cocktail Dress - Zara', price: '₹2,999', originalPrice: '₹4,999', image: '👗', category: 'Fashion'),
      SearchResult(title: 'Wedding Lehenga', price: '₹25,000', originalPrice: '₹35,000', image: '👗', category: 'Fashion'),
      SearchResult(title: 'Party Wear Gown', price: '₹4,500', originalPrice: '₹6,500', image: '👗', category: 'Fashion'),
      SearchResult(title: 'Casual Kurti Set', price: '₹1,299', originalPrice: '₹2,299', image: '👗', category: 'Fashion'),
      SearchResult(title: 'Formal Business Suit', price: '₹5,999', originalPrice: '₹8,999', image: '👔', category: 'Fashion'),
    ],
    'laptop': [
      SearchResult(title: 'MacBook Air M2 13-inch', price: '₹89,900', originalPrice: '₹1,09,900', image: '💻', category: 'Electronics'),
      SearchResult(title: 'MacBook Pro M3 14-inch', price: '₹1,49,900', originalPrice: '₹1,69,900', image: '💻', category: 'Electronics'),
      SearchResult(title: 'Dell XPS 13', price: '₹89,999', originalPrice: '₹1,09,999', image: '💻', category: 'Electronics'),
      SearchResult(title: 'HP Pavilion 15', price: '₹54,999', originalPrice: '₹69,999', image: '💻', category: 'Electronics'),
      SearchResult(title: 'Lenovo ThinkPad X1', price: '₹1,19,999', originalPrice: '₹1,39,999', image: '💻', category: 'Electronics'),
      SearchResult(title: 'ASUS ROG Gaming Laptop', price: '₹79,999', originalPrice: '₹99,999', image: '💻', category: 'Electronics'),
    ],
    'headphone': [
      SearchResult(title: 'Sony WH-1000XM5', price: '₹24,990', originalPrice: '₹29,990', image: '🎧', category: 'Electronics'),
      SearchResult(title: 'AirPods Pro 2nd Gen', price: '₹24,900', originalPrice: '₹29,900', image: '🎧', category: 'Electronics'),
      SearchResult(title: 'Bose QuietComfort 45', price: '₹29,900', originalPrice: '₹34,900', image: '🎧', category: 'Electronics'),
      SearchResult(title: 'Sennheiser HD 660S', price: '₹34,999', originalPrice: '₹39,999', image: '🎧', category: 'Electronics'),
      SearchResult(title: 'JBL Live Pro 2', price: '₹12,999', originalPrice: '₹16,999', image: '🎧', category: 'Electronics'),
      SearchResult(title: 'Beats Studio3 Wireless', price: '₹19,999', originalPrice: '₹24,999', image: '🎧', category: 'Electronics'),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _showSearchResults ? _buildSearchResults() : _buildSearchSuggestions(),
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
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for products, deals, and more...',
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
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
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
                color: Colors.black87,
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
              color: Colors.black87,
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
              color: Colors.black87,
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
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for products, deals, and more...',
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
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _showSearchResults = false;
                    _currentSearchQuery = '';
                  });
                },
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No results found for "$_currentSearchQuery"',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image container - matches the smaller rectangle in wireframe
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                result.image,
                style: const TextStyle(fontSize: 32),
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
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result.category,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  // Price
                  Text(
                    result.price,
                    style: const TextStyle(
                      fontSize: 12,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
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
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
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
        SearchResult(title: 'No results found', price: '', originalPrice: '', image: '❌', category: ''),
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
}

// Search Result Data Model
class SearchResult {
  final String title;
  final String price;
  final String originalPrice;
  final String image;
  final String category;

  SearchResult({
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.image,
    required this.category,
  });
}