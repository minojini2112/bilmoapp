import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'ai_reports_page.dart';
import 'news_page.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<dynamic>? products;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.products,
  });
}

class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<dynamic> searchResults = [];
  bool isLoading = true;
  String? errorMessage;
  Set<String> selectedStores = <String>{};
  List<String> availableStores = [];
  List<ChatMessage> chatMessages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isTyping = false;
  String currentLoadingPhrase = '';
  int loadingPhraseIndex = 0;
  List<String> suggestedItems = [];

  // Fun loading phrases
  final List<String> loadingPhrases = [
    "🔍 Scouring the digital shelves...",
    "🛍️ Hunting for the best deals...",
    "⚡ Lightning-fast search in progress...",
    "🎯 Finding your perfect match...",
    "💎 Digging up hidden gems...",
    "🚀 Zooming through product catalogs...",
    "🧠 AI brain working overtime...",
    "✨ Magic happening behind the scenes...",
    "🎪 The shopping circus is in town...",
    "🔥 Heating up the search engines...",
    "🌟 Stardust and shopping carts...",
    "🎨 Painting your perfect product...",
    "🎵 Harmonizing with e-commerce...",
    "🎭 The shopping show must go on...",
    "🎪 Juggling products and prices...",
    "🎨 Creating your shopping masterpiece...",
    "🎯 Bullseye! Finding your target...",
    "🚀 Launching into product space...",
    "💫 Wishing upon shopping stars...",
    "🎪 The greatest show on e-commerce...",
  ];

  // Dynamic backend URL detection
  String getBackendUrl() {
    return 'http://10.0.2.2:5000'; // Default for Android emulator
  }

  @override
  void initState() {
    super.initState();
    // Add user's initial query to chat
    chatMessages.add(ChatMessage(
      text: widget.query,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _performSearch();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    // Start loading animation
    _startLoadingAnimation();

    // Try different backend URLs for different platforms
    final List<String> possibleUrls = [
      'http://127.0.0.1:5000', // ADB port forwarding (should work for USB devices)
      'http://localhost:5000', // ADB port forwarding alternative
      'http://192.168.29.197:5000', // Your actual local network IP (Wi-Fi)
      'http://10.0.2.2:5000', // Android emulator
    ];
    
    print('🔍 Testing backend connectivity...');
    print('📱 Device type: ${Platform.isAndroid ? 'Android' : 'Other'}');
    print('🌐 Available URLs to try: $possibleUrls');

    for (String baseUrl in possibleUrls) {
      try {
        // First test basic connectivity
        print('🔍 Testing connectivity to: $baseUrl');
        final testResponse = await http.get(
          Uri.parse('$baseUrl/'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 5));
        
        if (testResponse.statusCode == 200) {
          print('✅ Backend is reachable at: $baseUrl');
        } else {
          print('⚠️ Backend responded with status: ${testResponse.statusCode}');
        }
        
        final url = '$baseUrl/search?query=${Uri.encodeComponent(widget.query)}&max_results=5&force_fresh=false';
        print('🔍 Trying GET request to: $url'); // Debug log
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));
        
        print('📡 Response status: ${response.statusCode}'); // Debug log

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('📊 API Response: ${data.toString()}'); // Debug log
          
          // Check if we have results (regardless of success field)
          if (data['results'] != null && data['results'].isNotEmpty) {
            setState(() {
              searchResults = data['results'];
              print('🏪 Search results count: ${searchResults.length}');
              
              // Flatten all products from all stores
              List<dynamic> allProducts = [];
              for (var store in searchResults) {
                print('🏬 Store: ${store['site']}, Products: ${store['products']?.length ?? 0}');
                if (store['products'] != null && store['products'].isNotEmpty) {
                  for (var product in store['products']) {
                    // Add store information to each product
                    product['site'] = store['site'] ?? 'Unknown';
                    allProducts.add(product);
                  }
                }
              }
              print('🛍️ Total products found: ${allProducts.length}');
              print('🏪 Available stores: ${searchResults.map((s) => s['site']).toList()}'); // Debug log
              
              // Debug: Print first product to see structure
              if (allProducts.isNotEmpty) {
                print('🔍 First product structure: ${allProducts.first.keys.toList()}');
                print('📝 First product data: ${allProducts.first}');
              }
              
              // Extract available stores for filtering
              availableStores = searchResults
                  .where((store) => store['products'] != null && store['products'].isNotEmpty)
                  .map((result) => result['site']?.toString() ?? 'Unknown')
                  .toSet()
                  .toList();
              selectedStores = availableStores.toSet(); // Select all stores by default
              
              print('🏪 Available stores for filtering: $availableStores');
              print('✅ Selected stores: $selectedStores');
              isLoading = false;
              
              // Add AI response to chat with flattened products
              if (allProducts.isNotEmpty) {
                chatMessages.add(ChatMessage(
                  text: "Here are the best deals I found for '${widget.query}':",
                  isUser: false,
                  timestamp: DateTime.now(),
                  products: allProducts,
                ));
                
                // Generate suggested items based on the search query
                _generateSuggestedItems(widget.query);
              } else {
                chatMessages.add(ChatMessage(
                  text: "I couldn't find any products for '${widget.query}'. Please try a different search term.",
                  isUser: false,
                  timestamp: DateTime.now(),
                ));
              }
            });
            _stopLoadingAnimation();
            return; // Success, exit the loop
          } else {
            print('❌ No results found in API response');
            print('📊 Response structure: ${data.keys.toList()}');
            setState(() {
              errorMessage = data['error'] ?? 'No results found. API response: ${data.toString()}';
              isLoading = false;
              
              // Add error message to chat
              chatMessages.add(ChatMessage(
                text: "Sorry, I couldn't find any results for '${widget.query}'. Please try a different search term.",
                isUser: false,
                timestamp: DateTime.now(),
              ));
            });
            _stopLoadingAnimation();
            return; // Error from API, exit the loop
          }
        }
      } catch (e) {
        print('❌ Failed to connect to $baseUrl: $e');
        continue; // Try next URL
      }
    }
    
    // If we reach here, all URLs failed
    setState(() {
      errorMessage = 'Could not connect to backend server.';
      isLoading = false;
      
      // Add error message to chat
      chatMessages.add(ChatMessage(
        text: "I'm having trouble connecting to the server. Please check your internet connection and try again.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _stopLoadingAnimation();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final message = _messageController.text.trim();
    _messageController.clear();
    
    // Add user message to chat
    setState(() {
      chatMessages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    
    // Scroll to bottom
    _scrollToBottom();
    
    // Start loading animation
    _startLoadingAnimation();
    
    // Simulate AI response (you can replace this with actual API call)
    await Future.delayed(const Duration(seconds: 3));
    
    setState(() {
      chatMessages.add(ChatMessage(
        text: "I understand you're looking for '$message'. Let me search for the best deals for you!",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    
    _stopLoadingAnimation();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startLoadingAnimation() {
    setState(() {
      isTyping = true;
      currentLoadingPhrase = loadingPhrases[loadingPhraseIndex];
    });
    
    // Change phrase every 2 seconds
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!isTyping) {
        timer.cancel();
        return;
      }
      
      setState(() {
        loadingPhraseIndex = (loadingPhraseIndex + 1) % loadingPhrases.length;
        currentLoadingPhrase = loadingPhrases[loadingPhraseIndex];
      });
    });
  }

  void _stopLoadingAnimation() {
    setState(() {
      isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bilmo AI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                chatMessages.clear();
                chatMessages.add(ChatMessage(
                  text: widget.query,
                  isUser: true,
                  timestamp: DateTime.now(),
                ));
                _performSearch();
              });
            },
          ),
        ],
      ),
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
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child: _buildChatMessages(),
            ),
            // Floating menu
            _buildFloatingMenu(),
            // Typing bar
            _buildTypingBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatMessages.length + (isTyping ? 1 : 0) + (suggestedItems.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == chatMessages.length && isTyping) {
          return _buildTypingIndicator();
        }
        
        // Show suggested items after the last message
        if (index == chatMessages.length + (isTyping ? 1 : 0) && suggestedItems.isNotEmpty) {
          return _buildSuggestedItemsSection();
        }
        
        final message = chatMessages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentLoadingPhrase,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTypingDot(0),
                      const SizedBox(width: 4),
                      _buildTypingDot(1),
                      const SizedBox(width: 4),
                      _buildTypingDot(2),
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

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3 + (value * 0.7)),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
      onEnd: () {
        if (isTyping) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildSuggestedItemsSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with catchy phrase - Fixed overflow
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.2),
                  Colors.blue.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.purple.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.yellow[300],
                  size: 18,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    '💡 Perfect Complements',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Things you might love',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Suggested items grid - Fixed layout
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: suggestedItems.map((item) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _onSuggestedItemTap(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_shopping_cart,
                            color: Colors.green[300],
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    if (message.isUser) {
      // User message with frame
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      );
    } else {
      // AI message completely without frame - just the content as part of page
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI response text without any frame or background
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Products grid without any frame
            if (message.products != null && message.products!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildProductGrid(message.products!),
              ),
            ],
          ],
        ),
      );
    }
  }

  Widget _buildProductGrid(List<dynamic> products) {
    // Filter products based on selected stores
    final filteredProducts = products.where((product) {
      final store = product['site']?.toString() ?? 'Unknown';
      return selectedStores.contains(store);
    }).toList();
    
    print('🔍 Total products: ${products.length}');
    print('🏪 Selected stores: $selectedStores');
    print('📦 Filtered products: ${filteredProducts.length}');

    return Column(
      children: [
        // Store Filter Chips
        if (availableStores.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildStoreFilterChips(),
          const SizedBox(height: 16),
        ],
        // Products Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75, // Adjusted for new card height
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return _buildProductCard(product);
          },
        ),
      ],
    );
  }

  Widget _buildStoreFilterChips() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableStores.length,
        itemBuilder: (context, index) {
          final store = availableStores[index];
          final isSelected = selectedStores.contains(store);
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    _getStoreLogoUrl(store),
                    width: 20,
                    height: 16,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to text if image fails to load
                      return Text(
                        _getStoreDisplayName(store),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getStoreDisplayName(store),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedStores.add(store);
                  } else {
                    selectedStores.remove(store);
                  }
                  print('🏪 Store filter changed: $selectedStores');
                });
              },
              selectedColor: Colors.red.withOpacity(0.3),
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.1),
              side: BorderSide(
                color: isSelected ? Colors.red : Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }

  String _getStoreDisplayName(String store) {
    switch (store.toLowerCase()) {
      case 'flipkart':
        return 'Flipkart';
      case 'amazon':
        return 'Amazon';
      case 'myntra':
        return 'Myntra';
      case 'meesho':
        return 'Meesho';
      default:
        return store;
    }
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    // Debug log to see what fields are available
    print('🔍 Product data: ${product.keys.toList()}');
    print('📝 Product title: ${product['title']}');
    print('💰 Product price: ${product['price']}');
    print('⭐ Product rating: ${product['rating']}');
    print('🖼️ Product image: ${product['image_url']}');
    print('🏪 Product site: ${product['site']}');
    
    return GestureDetector(
      onTap: () => _launchProductUrl(product['link']),
      child: Container(
        height: 200, // Increased height to prevent overflow
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: product['image_url'] != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              product['image_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('❌ Image load error: $error');
                                return const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white54,
                                  size: 20,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                            size: 20,
                          ),
                  ),
                ),
                // Product Details
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product['title'] ?? 'Unknown Product',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          product['price'] ?? 'Price not available',
                          style: TextStyle(
                            color: Colors.green[400],
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 8,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product['rating']?.toString() ?? 'N/A',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            if (product['discount_percentage'] != null && product['discount_percentage'].toString().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  product['discount_percentage'],
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Brand information if available
                        if (product['brand'] != null && product['brand'].toString().isNotEmpty)
                          Text(
                            product['brand'],
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 7,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        // Availability information if available
                        if (product['availability'] != null && product['availability'].toString().isNotEmpty)
                          Text(
                            product['availability'],
                            style: TextStyle(
                              color: Colors.blue[300],
                              fontSize: 6,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Floating Store Logo at top-left
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
                child: Image.network(
                  _getStoreLogoUrl(product['site'] ?? 'Unknown'),
                  width: 20,
                  height: 14,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to text if image fails to load
                    return Text(
                      _getStoreShortName(product['site'] ?? 'Unknown'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingMenu() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMenuOption(
            icon: Icons.local_offer,
            label: 'Best Deals',
            color: Colors.red,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Best Deals - Coming Soon!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
          _buildMenuOption(
            icon: Icons.psychology,
            label: 'AI Report',
            color: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AIReportsPage()),
              );
            },
          ),
          _buildMenuOption(
            icon: Icons.newspaper,
            label: 'News',
            color: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsPage()),
              );
            },
          ),
          _buildMenuOption(
            icon: Icons.video_library,
            label: 'Reels',
            color: Colors.red,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reels - Coming Soon!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Ask Bilmo anything...',
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStoreLogoUrl(String storeName) {
    switch (storeName.toLowerCase()) {
      case 'flipkart':
        return 'https://ik.imagekit.io/varsh0506/Bilmo/flipkart_smalll.png?updatedAt=1759306023827';
      case 'amazon':
        return 'https://ik.imagekit.io/varsh0506/Bilmo/amazon_small.png?updatedAt=1759302709675';
      case 'meesho':
        return 'https://ik.imagekit.io/varsh0506/Bilmo/Meesho_small.png?updatedAt=1759302709615';
      case 'myntra':
        return 'https://ik.imagekit.io/varsh0506/Bilmo/myntra_small.png?updatedAt=1759302709491'; // Myntra logo
      default:
        return 'https://ik.imagekit.io/varsh0506/Bilmo/default_small.png?updatedAt=1759302709491'; // Default logo
    }
  }

  String _getStoreShortName(String storeName) {
    switch (storeName.toLowerCase()) {
      case 'flipkart':
        return 'FK';
      case 'amazon':
        return 'AZ';
      case 'myntra':
        return 'MY';
      case 'meesho':
        return 'MS';
      default:
        return storeName.substring(0, 2).toUpperCase();
    }
  }

  void _generateSuggestedItems(String query) {
    // For now, use static sample data - will be replaced with backend later
    suggestedItems = [
      'wireless mouse',
      'laptop charger',
      'keyboard',
      'laptop bag',
      'mouse pad',
      'USB hub',
      'laptop stand',
      'external hard drive'
    ];
    
    setState(() {});
  }

  void _onSuggestedItemTap(String suggestedItem) {
    // Add user message for the suggested item
    chatMessages.add(ChatMessage(
      text: suggestedItem,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    
    // Perform search for the suggested item
    _performSuggestedSearch(suggestedItem);
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _performSuggestedSearch(String query) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    _startLoadingAnimation();

    // List of possible backend URLs to try
    final List<String> possibleUrls = [
      'http://127.0.0.1:5000', // For ADB port forwarding
      'http://10.0.2.2:5000', // For Android emulator
      'http://192.168.29.197:5000', // Your local IP
      'http://localhost:5000', // Fallback
    ];

    for (String baseUrl in possibleUrls) {
      try {
        final url = '$baseUrl/search?query=${Uri.encodeComponent(query)}&max_results=5&force_fresh=false';
        print('🔍 Trying GET request to: $url'); // Debug log
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        print('📡 Response status: ${response.statusCode}');
        print('📡 Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('✅ Successfully got data: $data');

          setState(() {
            searchResults = data['results'] ?? [];
            isLoading = false;
            
            // Extract available stores for filtering
            availableStores.clear();
            for (var store in searchResults) {
              if (store['site'] != null) {
                availableStores.add(store['site']);
              }
            }
            
            print('🏪 Available stores for filtering: $availableStores');
            print('✅ Selected stores: $selectedStores');
            isLoading = false;
            
            // Flatten all products from all stores
            List<dynamic> allProducts = [];
            for (var store in searchResults) {
              if (store['products'] != null && store['products'].isNotEmpty) {
                for (var product in store['products']) {
                  // Add store information to each product
                  product['site'] = store['site'] ?? 'Unknown';
                  allProducts.add(product);
                }
              }
            }
            
            // Add AI response to chat with flattened products
            if (allProducts.isNotEmpty) {
              chatMessages.add(ChatMessage(
                text: "Here are the best deals I found for '$query':",
                isUser: false,
                timestamp: DateTime.now(),
                products: allProducts,
              ));
              
              // Generate suggested items based on the search query
              _generateSuggestedItems(query);
            } else {
              chatMessages.add(ChatMessage(
                text: "I couldn't find any products for '$query'. Please try a different search term.",
                isUser: false,
                timestamp: DateTime.now(),
              ));
            }
          });
          _stopLoadingAnimation();
          return; // Success, exit the loop
        } else {
          setState(() {
            errorMessage = 'Server returned status ${response.statusCode}';
            isLoading = false;
          });
        }
      } catch (e) {
        print('❌ Error with $baseUrl: $e');
        print('🔍 Error type: ${e.runtimeType}');
        if (e.toString().contains('SocketException')) {
          print('🌐 Network connection issue - check if backend is running');
        } else if (e.toString().contains('TimeoutException')) {
          print('⏰ Request timeout - backend might be slow');
        }
        setState(() {
          errorMessage = 'Connection failed with $baseUrl: $e';
          isLoading = false;
        });
      }
    }
    
    _stopLoadingAnimation();
  }

  Future<void> _launchProductUrl(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product link not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot open product link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening link: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}