import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'ai_reports_page.dart';
import 'news_page.dart';
import 'youtube_shorts_working.dart';
import 'api_service.dart';

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
  
  // AI data storage
  List<Map<String, dynamic>> aiReports = [];
  List<Map<String, dynamic>> newsData = [];
  List<Map<String, dynamic>> similarProducts = [];
  String currentProduct = '';
  
  // AI loading states
  bool isAiDataLoading = true;

  // Fun loading phrases - extended for longer searches (5+ minutes)
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
    "⏰ Taking time to find the best deals...",
    "🔄 Deep scanning multiple stores...",
    "📊 Analyzing thousands of products...",
    "🤖 AI is working hard for you...",
    "💪 Powering through massive catalogs...",
    "🎯 Precision targeting the best prices...",
    "🔬 Scientific shopping in progress...",
    "🌍 Searching across the globe...",
    "⚙️ Fine-tuning the perfect results...",
    "🎪 The search circus continues...",
    "🚀 Still zooming through data...",
    "💎 Still digging for gems...",
    "🧠 AI is still thinking...",
    "✨ More magic happening...",
    "🔥 Still heating up...",
    "🌟 Still collecting stardust...",
    "🎨 Still painting your results...",
    "🎵 Still harmonizing...",
    "🎭 The show continues...",
    "⏳ Patience is a virtue...",
    "🔄 Still scanning...",
    "📊 Still analyzing...",
    "🤖 AI is still working...",
    "💪 Still powering through...",
    "🎯 Still targeting...",
    "🔬 Still researching...",
    "🌍 Still searching globally...",
    "⚙️ Still fine-tuning...",
    "🎪 Juggling products and prices...",
    "🎨 Creating your shopping masterpiece...",
    "🎯 Bullseye! Finding your target...",
    "🚀 Launching into product space...",
    "💫 Wishing upon shopping stars...",
    "🎪 The greatest show on e-commerce...",
    "🕷️ Web scraping in progress...",
    "🤖 AI analyzing market trends...",
    "📊 Processing product data...",
    "🔍 Deep diving into deals...",
    "⚡ Powering up search engines...",
    "🎯 Targeting the best offers...",
    "💎 Mining for hidden treasures...",
    "🚀 Exploring the product universe...",
    "🧠 Smart algorithms at work...",
    "✨ Crafting your perfect results...",
  ];

  // Dynamic backend URL detection
  String getBackendUrl() {
    return 'https://bilmobackend-production.up.railway.app'; // Production URL
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
    
    // Store current product for AI data
    currentProduct = widget.query;

    // Make dual API calls: search products and get AI data
    print('🔍 Starting dual API calls for: ${widget.query}');
    
    // Test connectivity first (for debugging)
    await ApiService.testConnectivity();
    
    // Add a message after 30 seconds to inform user about long search
    Timer(const Duration(seconds: 30), () {
      if (isLoading) {
        setState(() {
          chatMessages.add(ChatMessage(
            text: "🔍 This search is taking longer than usual - we're scanning multiple stores to find you the best deals. Please hang tight!",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
    
    // Start both API calls in parallel but don't wait for both
    final searchFuture = ApiService.searchProducts(widget.query);
    final newsFuture = ApiService.getProductNews(widget.query);
    
    // Note: Removed minimum loading time since we're not waiting for both APIs
    
    // Wait for search results first (don't wait for news API)
    final searchData = await searchFuture;
    
    // Process search results immediately when available
    if (searchData != null && searchData['results'] != null && searchData['results'].isNotEmpty) {
      setState(() {
        searchResults = searchData['results'];
        print('🏪 Search results count: ${searchResults.length}');
        
        // Flatten all products from all stores
        List<dynamic> allProducts = [];
        for (var store in searchResults) {
          print('🏬 Store: ${store['site']}, Products: ${store['products']?.length ?? 0}');
          
          // Check different product arrays based on store structure
          List<dynamic> storeProducts = [];
          
          // Myntra uses 'products' array
          if (store['products'] != null && store['products'].isNotEmpty) {
            storeProducts.addAll(store['products']);
          }
          
          // Flipkart, Amazon, Meesho use 'basic_products' and 'detailed_products' arrays
          if (store['basic_products'] != null && store['basic_products'].isNotEmpty) {
            storeProducts.addAll(store['basic_products']);
          }
          
          if (store['detailed_products'] != null && store['detailed_products'].isNotEmpty) {
            storeProducts.addAll(store['detailed_products']);
          }
          
          // Add store information to each product and normalize the data
          for (var product in storeProducts) {
            // Add store information
            product['site'] = store['site'] ?? 'Unknown';
            
            // Normalize product data - handle different field names
            _normalizeProductData(product);
            
            allProducts.add(product);
          }
        }
        print('🛍️ Total products found: ${allProducts.length}');
        
        // Extract available stores for filtering
        availableStores = searchResults
            .where((store) {
              // Check if store has any products in any of the possible arrays
              return (store['products'] != null && store['products'].isNotEmpty) ||
                     (store['basic_products'] != null && store['basic_products'].isNotEmpty) ||
                     (store['detailed_products'] != null && store['detailed_products'].isNotEmpty);
            })
            .map((result) => result['site']?.toString() ?? 'Unknown')
            .toSet()
            .toList();
        selectedStores = availableStores.toSet(); // Select all stores by default
        
        print('🏪 Available stores for filtering: $availableStores');
        print('✅ Selected stores: $selectedStores');
        
        // Add AI response to chat with flattened products
        if (allProducts.isNotEmpty) {
          chatMessages.add(ChatMessage(
            text: "Here are the best deals I found for '${widget.query}':",
            isUser: false,
            timestamp: DateTime.now(),
            products: allProducts,
          ));
        } else {
          // Only show no results message if we actually got a response but no products
          chatMessages.add(ChatMessage(
            text: "I couldn't find any products for '${widget.query}'. Please try a different search term.",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        }
      });
      
      // Stop loading animation for search results
      setState(() {
        isLoading = false;
      });
      _stopLoadingAnimation();
    } else if (searchData != null) {
      // We got a response but no results - this is a real "no results" case
      setState(() {
        chatMessages.add(ChatMessage(
          text: "Sorry, I couldn't find any results for '${widget.query}'. Please try a different search term.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        isLoading = false;
      });
      _stopLoadingAnimation();
    } else {
      // No response at all - this means API call failed or timed out
      setState(() {
        errorMessage = 'Could not connect to backend server.';
        chatMessages.add(ChatMessage(
          text: "I'm having trouble connecting to the server. Please check your internet connection and try again.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        isLoading = false;
      });
      _stopLoadingAnimation();
    }
    
    // Now handle the news API separately (don't block the UI)
    _handleNewsApiAsync(newsFuture);
  }

  // Handle news API asynchronously without blocking the UI
  Future<void> _handleNewsApiAsync(Future<Map<String, dynamic>?> newsFuture) async {
    try {
      final newsApiData = await newsFuture;
      
      // Process AI data (reports, news, similar products)
      if (newsApiData != null && newsApiData['data'] != null) {
        setState(() {
          aiReports = List<Map<String, dynamic>>.from(newsApiData['data']['reports'] ?? []);
          newsData = List<Map<String, dynamic>>.from(newsApiData['data']['news'] ?? []);
          similarProducts = List<Map<String, dynamic>>.from(newsApiData['data']['repurchase'] ?? []);
          isAiDataLoading = false; // AI data loaded
          
          print('📊 AI Reports: ${aiReports.length}');
          print('📰 News items: ${newsData.length}');
          print('🛍️ Similar products: ${similarProducts.length}');
          
          // Generate suggested items from AI data
          _generateSuggestedItemsFromAI();
        });
      } else {
        print('⚠️ No AI data received, using fallback suggestions');
        setState(() {
          isAiDataLoading = false; // Stop loading even if no data
        });
        _generateSuggestedItems(widget.query);
      }
    } catch (e) {
      print('❌ News API failed: $e');
      setState(() {
        isAiDataLoading = false; // Stop loading on error
      });
      // Use fallback suggestions if news API fails
      _generateSuggestedItems(widget.query);
    }
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
    
    // Change phrase every 3 seconds (increased for better UX)
    Timer.periodic(const Duration(seconds: 3), (timer) {
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
                    '💡 Perfect Picks',
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
          // Suggested items grid - Creative loading animation
          if (isAiDataLoading)
            _buildCreativeLoadingAnimation()
          else
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
            icon: isAiDataLoading ? Icons.hourglass_empty : Icons.psychology,
            label: isAiDataLoading ? 'Loading...' : 'AI Report',
            color: isAiDataLoading ? Colors.orange : Colors.red,
            onTap: isAiDataLoading ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AIReportsPage(
                  reports: aiReports,
                  product: currentProduct,
                )),
              );
            },
          ),
          _buildMenuOption(
            icon: isAiDataLoading ? Icons.hourglass_empty : Icons.newspaper,
            label: isAiDataLoading ? 'Loading...' : 'News',
            color: isAiDataLoading ? Colors.orange : Colors.red,
            onTap: isAiDataLoading ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewsPage(
                  news: newsData,
                  product: currentProduct,
                )),
              );
            },
          ),
          _buildMenuOption(
            icon: Icons.video_library,
            label: 'Reels',
            color: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => YouTubeShortsWorking(
                    searchQuery: widget.query,
                  ),
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
    VoidCallback? onTap,
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
        return 'https://ik.imagekit.io/varsh0506/Bilmo/myntra_logo.jpg?updatedAt=1759399069138'; // Myntra logo
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

  void _generateSuggestedItemsFromAI() {
    // Generate suggested items from AI similar products data
    suggestedItems = similarProducts.take(8).map((product) {
      return product['name']?.toString() ?? 'Unknown Product';
    }).toList();
    
    // If we don't have enough AI suggestions, add some fallback items
    if (suggestedItems.length < 4) {
      suggestedItems.addAll([
        'wireless mouse',
        'laptop charger',
        'keyboard',
        'laptop bag',
      ]);
    }
    
    setState(() {});
  }

  void _normalizeProductData(Map<String, dynamic> product) {
    // Handle different field names used by different stores
    // Title/Name normalization - try multiple field names
    String? title;
    if (product['title'] != null && product['title'].toString().isNotEmpty) {
      title = product['title'].toString();
    } else if (product['name'] != null && product['name'].toString().isNotEmpty) {
      title = product['name'].toString();
    } else if (product['description'] != null && product['description'].toString().isNotEmpty) {
      title = product['description'].toString();
    } else if (product['brand'] != null && product['brand'].toString().isNotEmpty) {
      title = product['brand'].toString();
    }
    
    // Set both title and name for consistency
    if (title != null) {
      product['title'] = title;
      product['name'] = title;
    }
    
    // Image URL normalization
    if (product['image_url'] == null) {
      // Try different image field names
      if (product['image'] != null) {
        if (product['image'] is String) {
          product['image_url'] = product['image'];
        } else if (product['image'] is Map && product['image']['url'] != null) {
          product['image_url'] = product['image']['url'];
        }
      }
      
      // Try images array (for detailed products)
      if (product['images'] != null && product['images'] is List && product['images'].isNotEmpty) {
        var firstImage = product['images'][0];
        if (firstImage is Map && firstImage['url'] != null) {
          product['image_url'] = firstImage['url'];
        }
      }
      
      // Try image_thumbnail field
      if (product['image_thumbnail'] != null) {
        product['image_url'] = product['image_thumbnail'];
      }
    }
    
    // Rating normalization
    if (product['rating'] == null && product['reviews_count'] != null) {
      // Some stores put rating in reviews_count field
      var ratingStr = product['reviews_count'].toString();
      var ratingMatch = RegExp(r'(\d+\.?\d*)').firstMatch(ratingStr);
      if (ratingMatch != null) {
        product['rating'] = double.tryParse(ratingMatch.group(1) ?? '0');
      }
    }
    
    // Ensure we have a valid title
    if (product['title'] == null || product['title'].toString().isEmpty) {
      product['title'] = 'Product from ${product['site'] ?? 'Unknown Store'}';
    }
    
    print('📝 Normalized product: ${product['title']} - ${product['price']} - ${product['image_url']}');
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
    
    // Store current product for AI data
    currentProduct = query;

    // Use the same improved API service
    print('🔍 Starting suggested search for: $query');
    
    // Start both API calls in parallel
    final searchFuture = ApiService.searchProducts(query);
    final newsFuture = ApiService.getProductNews(query);
    
    // Ensure minimum loading time of 2 seconds for better UX
    final minLoadingTime = Future.delayed(const Duration(seconds: 2));
    
    // Wait for both API calls and minimum loading time
    final results = await Future.wait([
      searchFuture,
      newsFuture,
      minLoadingTime,
    ]);
    final searchData = results[0];
    final newsApiData = results[1];
    
    // Process search results
    if (searchData != null && searchData['results'] != null && searchData['results'].isNotEmpty) {
      setState(() {
        searchResults = searchData['results'];
        
        // Extract available stores for filtering
        availableStores.clear();
        for (var store in searchResults) {
          if (store['site'] != null) {
            availableStores.add(store['site']);
          }
        }
        
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
        } else {
          chatMessages.add(ChatMessage(
            text: "I couldn't find any products for '$query'. Please try a different search term.",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        }
      });
    } else {
      setState(() {
        chatMessages.add(ChatMessage(
          text: "Sorry, I couldn't find any results for '$query'. Please try a different search term.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
    
    // Process AI data (reports, news, similar products)
    if (newsApiData != null && newsApiData['data'] != null) {
      setState(() {
        aiReports = List<Map<String, dynamic>>.from(newsApiData['data']['reports'] ?? []);
        newsData = List<Map<String, dynamic>>.from(newsApiData['data']['news'] ?? []);
        similarProducts = List<Map<String, dynamic>>.from(newsApiData['data']['repurchase'] ?? []);
        
        // Generate suggested items from AI data
        _generateSuggestedItemsFromAI();
      });
    } else {
      _generateSuggestedItems(query);
    }
    
    setState(() {
      isLoading = false;
    });
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

  Widget _buildCreativeLoadingAnimation() {
    return Container(
      height: 120,
      child: Column(
        children: [
          // Animated loading text with pulsing effect
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.5, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.withOpacity(0.3),
                          Colors.blue.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.purple.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated brain icon
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 2000),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.rotate(
                              angle: value * 2 * 3.14159,
                              child: Icon(
                                Icons.psychology,
                                color: Colors.purple[300],
                                size: 16,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '🧠 AI is thinking...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            onEnd: () {
              // Restart animation
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          // Skeleton loading cards
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3, // Show 3 skeleton cards
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      // Animated skeleton card
                      TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 1000 + (index * 200)),
                        tween: Tween(begin: 0.3, end: 1.0),
                        builder: (context, value, child) {
                          return Container(
                            height: 60,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1 * value),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.purple.withOpacity(0.3 * value),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.purple.withOpacity(0.5 * value),
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      // Animated skeleton text
                      TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 1200 + (index * 200)),
                        tween: Tween(begin: 0.2, end: 1.0),
                        builder: (context, value, child) {
                          return Container(
                            height: 12,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2 * value),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Animated dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600 + (index * 200)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Transform.scale(
                      scale: 0.5 + (0.5 * value),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.3 + (0.7 * value)),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}