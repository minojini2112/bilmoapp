import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'search.dart';
import 'pages.dart';
import 'section_pages.dart';
import 'book_flights_page.dart';
import 'hotel_bookings_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BILMO AI',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class SparkleWidget extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  final double angle;

  const SparkleWidget({
    super.key,
    required this.size,
    required this.color,
    required this.opacity,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(opacity),
          shape: BoxShape.circle,
        ),
        child: CustomPaint(
          painter: SparklePainter(color: color, opacity: opacity),
        ),
      ),
    );
  }
}

class SparklePainter extends CustomPainter {
  final Color color;
  final double opacity;

  SparklePainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw sparkle shape (4-pointed star)
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx + radius * 0.3, center.dy - radius * 0.3);
    path.lineTo(center.dx + radius, center.dy);
    path.lineTo(center.dx + radius * 0.3, center.dy + radius * 0.3);
    path.lineTo(center.dx, center.dy + radius);
    path.lineTo(center.dx - radius * 0.3, center.dy + radius * 0.3);
    path.lineTo(center.dx - radius, center.dy);
    path.lineTo(center.dx - radius * 0.3, center.dy - radius * 0.3);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  bool _isDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      drawer: _buildDrawer(),
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
              // Mobile Header with Hamburger Menu
              _buildMobileHeader(),
              // Main content
              Expanded(
                child: _selectedIndex == 0 ? _buildHomeContent() : _buildDashboardContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Hamburger Menu and BILMO Logo
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
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
          // Sign In Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'SIGN IN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A2E),
      child: Container(
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
              // Drawer Header
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
              // Navigation Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem('DASHBOARD', Icons.dashboard, 0),
                    _buildDrawerItem('BEST DEALS', Icons.local_offer, -1),
                    _buildDrawerItem('AI REPORT', Icons.analytics, -2),
                    _buildDrawerItem('CART', Icons.shopping_cart, -3),
                    _buildDrawerItem('WISHLIST', Icons.favorite, -4),
                    _buildDrawerItem('ABOUT US', Icons.info, 1),
                    _buildDrawerItem('PRICING', Icons.attach_money, 2),
                    _buildDrawerItem('CONTACT US', Icons.contact_mail, 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        setState(() {
          _selectedIndex = index;
        });
        // Navigate to specific pages
        if (index == -1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BestDealsPage()),
          );
        } else if (index == -2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AIReportPage()),
          );
        } else if (index == -3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartPage()),
          );
        } else if (index == -4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WishlistPage()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutUsPage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PricingPage()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactUsPage()),
          );
        }
      },
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // Main Hero Section - Magically Smart Text with Static Sparkles
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main text - Static white text
                const Text(
                  'Magically\nSmart',
                  style: TextStyle(
                    fontFamily: 'Back to Black Demo',
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                    height: 1.1,
                    letterSpacing: 3.0,
                    shadows: [
                      Shadow(
                        color: Colors.white24,
                        blurRadius: 15,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                // Static white sparkles around the text
                ...List.generate(6, (index) {
                  final random = Random(index);
                  return Positioned(
                    left: 40 + (random.nextDouble() * 220),
                    top: 20 + (random.nextDouble() * 120),
                    child: SparkleWidget(
                      size: 6 + (random.nextDouble() * 8),
                      color: Colors.white,
                      opacity: 0.7 + (random.nextDouble() * 0.3),
                      angle: random.nextDouble() * 2 * pi,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Search Section
          _buildSearchSection(),
          const SizedBox(height: 30),
          // Main Content Grid - 2x2 layout (Wider)
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildSectionCard('Best Deals', Icons.local_offer, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BestDealsPage()),
                      );
                    }),
                    const SizedBox(height: 12),
                    _buildSectionCard('AI Report', Icons.analytics, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AIReportPage()),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _buildSectionCard('Cart', Icons.shopping_cart, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartPage()),
                      );
                    }),
                    const SizedBox(height: 12),
                    _buildSectionCard('Wishlist', Icons.favorite, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WishlistPage()),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Explore Section
          const Text(
            'Explore',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Explore Options - Sequential Layout
          _buildExploreOption('Book Flights', Icons.flight, '✈️', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookFlightsPage()),
            );
          }),
          const SizedBox(height: 12),
          _buildExploreOption('Hotel Bookings', Icons.hotel, '🏨', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HotelBookingsPage()),
            );
          }),
          const SizedBox(height: 12),
          _buildExploreOption('Fashion & Style', Icons.checkroom, '👗', () {
            // Navigate to fashion page or show fashion deals
          }),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120, // Made bigger
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16), // More rounded
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 36, // Made bigger
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16, // Made bigger
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreOption(String title, IconData icon, String emoji, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
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
                borderRadius: BorderRadius.circular(10),
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
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover amazing deals',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              icon,
              color: Colors.white70,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Search products',
                hintStyle: TextStyle(color: Colors.white70, fontSize: 16),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_searchController.text.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(searchQuery: _searchController.text),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.search,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Input Fields
          Row(
            children: [
              Expanded(
                child: _buildSearchInput('Search Input 1'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSearchInput('Search Input 2'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSearchInput('Search Input 3'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search Result Panel
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Center(
              child: Text(
                'Search Result',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Bottom Row
          Row(
            children: [
              Expanded(
                child: _buildDashboardCard('Ai Report'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDashboardCard(''),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDashboardCard('CART\nWatchlist'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput(String hint) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String text) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: text.isEmpty
            ? null
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
