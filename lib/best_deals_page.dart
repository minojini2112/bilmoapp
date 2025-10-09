import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'dart:async';

class BestDealsPage extends StatefulWidget {
  const BestDealsPage({super.key});

  @override
  State<BestDealsPage> createState() => _BestDealsPageState();
}

class _BestDealsPageState extends State<BestDealsPage> {
  // Data storage for each platform
  Map<String, dynamic> amazonDeals = {};
  Map<String, dynamic> flipkartDeals = {};
  Map<String, dynamic> myntraDeals = {};
  
  // Loading states for each platform
  bool amazonLoading = true;
  bool flipkartLoading = true;
  bool myntraLoading = true;
  
  // Error states for each platform
  String? amazonError;
  String? flipkartError;
  String? myntraError;
  
  // Selected platform filter
  String selectedPlatform = 'All';
  List<String> platforms = ['All', 'Amazon', 'Flipkart', 'Myntra'];

  @override
  void initState() {
    super.initState();
    _loadAllDeals();
  }

  Future<void> _loadAllDeals() async {
    setState(() {
      amazonLoading = true;
      flipkartLoading = true;
      myntraLoading = true;
      amazonError = null;
      flipkartError = null;
      myntraError = null;
    });

    // Start all 3 API calls in parallel
    _loadAmazonDeals();
    _loadFlipkartDeals();
    _loadMyntraDeals();

    print('🚀 Started loading deals from all platforms');
  }

  Future<void> _loadAmazonDeals() async {
    try {
      final deals = await ApiService.getUnifiedDeals('Amazon');
      setState(() {
        amazonDeals = deals ?? {};
        amazonLoading = false;
      });
      print('✅ Amazon deals loaded: ${amazonDeals['sections']?.length ?? 0} sections');
    } catch (e) {
      print('❌ Amazon deals error: $e');
      setState(() {
        amazonLoading = false;
        amazonError = e.toString();
      });
    }
  }

  Future<void> _loadFlipkartDeals() async {
    try {
      final deals = await ApiService.getUnifiedDeals('Flipkart');
      setState(() {
        flipkartDeals = deals ?? {};
        flipkartLoading = false;
      });
      print('✅ Flipkart deals loaded: ${flipkartDeals['sections']?.length ?? 0} sections');
    } catch (e) {
      print('❌ Flipkart deals error: $e');
      setState(() {
        flipkartLoading = false;
        flipkartError = e.toString();
      });
    }
  }

  Future<void> _loadMyntraDeals() async {
    try {
      final deals = await ApiService.getUnifiedDeals('Myntra');
      setState(() {
        myntraDeals = deals ?? {};
        myntraLoading = false;
      });
      print('✅ Myntra deals loaded: ${myntraDeals['sections']?.length ?? 0} sections');
    } catch (e) {
      print('❌ Myntra deals error: $e');
      setState(() {
        myntraLoading = false;
        myntraError = e.toString();
      });
    }
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
          'Best Deals',
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
            onPressed: _loadAllDeals,
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
            // Platform Filter Chips
            _buildPlatformFilter(),
            // Main Content
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: platforms.length,
        itemBuilder: (context, index) {
          final platform = platforms[index];
          final isSelected = selectedPlatform == platform;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (platform != 'All') ...[
                    _buildPlatformIcon(platform),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    platform,
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
                  selectedPlatform = platform;
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

  Widget _buildPlatformIcon(String platform) {
    String imageUrl;
    switch (platform) {
      case 'Amazon':
        imageUrl = 'https://ik.imagekit.io/varsh0506/Bilmo/amazon_small.png?updatedAt=1759302709675';
        break;
      case 'Flipkart':
        imageUrl = 'https://ik.imagekit.io/varsh0506/Bilmo/flipkart_smalll.png?updatedAt=1759306023827';
        break;
      case 'Myntra':
        imageUrl = 'https://ik.imagekit.io/varsh0506/Bilmo/myntra_logo.jpg?updatedAt=1759399069138';
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return Image.network(
      imageUrl,
      width: 16,
      height: 16,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.store,
          size: 16,
          color: Colors.white70,
        );
      },
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amazon Deals
          if (selectedPlatform == 'All' || selectedPlatform == 'Amazon')
            _buildPlatformSection(
              'Amazon',
              amazonLoading,
              amazonError,
              amazonDeals,
              Colors.orange,
            ),
          
          // Flipkart Deals
          if (selectedPlatform == 'All' || selectedPlatform == 'Flipkart')
            _buildPlatformSection(
              'Flipkart',
              flipkartLoading,
              flipkartError,
              flipkartDeals,
              Colors.blue,
            ),
          
          // Myntra Deals
          if (selectedPlatform == 'All' || selectedPlatform == 'Myntra')
            _buildPlatformSection(
              'Myntra',
              myntraLoading,
              myntraError,
              myntraDeals,
              Colors.pink,
            ),
        ],
      ),
    );
  }

  Widget _buildPlatformSection(
    String platformName,
    bool isLoading,
    String? error,
    Map<String, dynamic> deals,
    Color accentColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Platform Header
          _buildPlatformHeader(platformName, isLoading, error, deals, accentColor),
          
          const SizedBox(height: 16),
          
          // Content
          if (isLoading)
            _buildLoadingSection(platformName, accentColor)
          else if (error != null)
            _buildErrorSection(platformName, error, accentColor)
          else if (deals.isNotEmpty && deals['sections'] != null)
            _buildDealsContent(deals['sections'], accentColor)
          else
            _buildEmptySection(platformName, accentColor),
        ],
      ),
    );
  }

  Widget _buildPlatformHeader(String platformName, bool isLoading, String? error, Map<String, dynamic> deals, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildPlatformIcon(platformName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platformName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLoading)
                  Text(
                    'Loading deals...',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                    ),
                  )
                else if (error != null)
                  Text(
                    'Failed to load',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  )
                else
                  Text(
                    '${deals['sections']?.length ?? 0} sections available',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingSection(String platformName, Color accentColor) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading ${platformName} deals...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(String platformName, String error, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load ${platformName} deals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String platformName, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            color: Colors.white54,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'No deals available',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealsContent(List<dynamic> sections, Color accentColor) {
    return Column(
      children: sections.map((section) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildDealSection(section, accentColor),
        );
      }).toList(),
    );
  }

  Widget _buildDealSection(Map<String, dynamic> section, Color accentColor) {
    final sectionTitle = section['section_title'] ?? 'Deals';
    final items = section['items'] ?? [];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_offer,
                  color: accentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sectionTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length} items',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Items Grid
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildDealItem(items[index], accentColor);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDealItem(Map<String, dynamic> item, Color accentColor) {
    final title = item['title'] ?? 'Unknown Item';
    final image = item['image'] ?? '';
    final price = item['price'] ?? '';
    final discount = item['discount'] ?? '';
    final link = item['link'] ?? '';
    
    // Debug print to see what data we're getting
    print('🖼️ Product: $title');
    print('🖼️ Image URL: $image');
    print('💰 Price: $price');
    print('🏷️ Discount: $discount');
    
    return GestureDetector(
      onTap: () => _launchUrl(link),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        child: Image.network(
                          image,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('❌ Image load error for $image: $error');
                            return Container(
                              color: Colors.white.withOpacity(0.1),
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.white54,
                                size: 32,
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        color: Colors.white.withOpacity(0.1),
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                          size: 32,
                        ),
                      ),
              ),
            ),
            
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (price.isNotEmpty)
                      Flexible(
                        child: Text(
                          price,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (discount.isNotEmpty)
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            discount,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot open link'),
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

// Placeholder pages for missing classes
class CartPage extends StatelessWidget {
  const CartPage({super.key});

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
          'Cart',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Cart - Coming Soon!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

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
          'Wishlist',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Wishlist - Coming Soon!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class AIReportPage extends StatelessWidget {
  const AIReportPage({super.key});

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
          'AI Report',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AI Report - Coming Soon!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}