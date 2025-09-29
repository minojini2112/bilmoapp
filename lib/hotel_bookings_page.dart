import 'package:flutter/material.dart';

class HotelBookingsPage extends StatefulWidget {
  const HotelBookingsPage({super.key});

  @override
  State<HotelBookingsPage> createState() => _HotelBookingsPageState();
}

class _HotelBookingsPageState extends State<HotelBookingsPage> {
  final TextEditingController _destinationController = TextEditingController(text: 'Paris');
  final TextEditingController _checkInController = TextEditingController(text: '2024-02-15');
  final TextEditingController _checkOutController = TextEditingController(text: '2024-02-18');
  final TextEditingController _guestsController = TextEditingController(text: '2');
  final TextEditingController _roomsController = TextEditingController(text: '1');
  
  String _selectedPriceRange = 'Any';
  String _selectedRating = 'Any';
  
  final List<String> _priceRanges = ['Any', '\$0-100', '\$100-200', '\$200-300', '\$300+'];
  final List<String> _ratings = ['Any', '3+ Stars', '4+ Stars', '5 Stars'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
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
              _buildHeader(),
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Form
                      _buildSearchForm(),
                      const SizedBox(height: 30),
                      // Popular Hotels
                      _buildPopularHotels(),
                      const SizedBox(height: 30),
                      // Hotel Deals
                      _buildHotelDeals(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.hotel, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          const Text(
            'Hotel Bookings',
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

  Widget _buildSearchForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search Hotels',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Destination
          _buildTextField('Destination', _destinationController, Icons.location_on),
          const SizedBox(height: 16),
          // Check-in and Check-out
          Row(
            children: [
              Expanded(child: _buildTextField('Check-in', _checkInController, Icons.calendar_today)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Check-out', _checkOutController, Icons.calendar_today)),
            ],
          ),
          const SizedBox(height: 16),
          // Guests and Rooms
          Row(
            children: [
              Expanded(child: _buildTextField('Guests', _guestsController, Icons.person)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Rooms', _roomsController, Icons.bed)),
            ],
          ),
          const SizedBox(height: 16),
          // Price Range and Rating
          Row(
            children: [
              Expanded(child: _buildDropdown('Price Range', _selectedPriceRange, _priceRanges, (value) {
                setState(() => _selectedPriceRange = value!);
              })),
              const SizedBox(width: 16),
              Expanded(child: _buildDropdown('Rating', _selectedRating, _ratings, (value) {
                setState(() => _selectedRating = value!);
              })),
            ],
          ),
          const SizedBox(height: 24),
          // Search Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _searchHotels(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Search Hotels',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: Colors.white),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularHotels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Destinations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130, // Increased height to accommodate content better
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildDestinationCard('Paris', '🇫🇷', '₹9,960/night'),
              const SizedBox(width: 12),
              _buildDestinationCard('Tokyo', '🇯🇵', '₹12,450/night'),
              const SizedBox(width: 12),
              _buildDestinationCard('Dubai', '🇦🇪', '₹16,600/night'),
              const SizedBox(width: 12),
              _buildDestinationCard('New York', '🇺🇸', '₹14,940/night'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationCard(String city, String flag, String price) {
    return Container(
      width: 120, // Increased width to accommodate longer text
      padding: const EdgeInsets.all(12), // Reduced padding to give more space for content
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            city,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHotelDeals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Best Hotel Deals',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildHotelDealCard(
          'The Ritz Paris',
          'Paris, France',
          '₹26,560',
          '5 Stars',
          'Luxury',
          Icons.hotel,
        ),
        const SizedBox(height: 12),
        _buildHotelDealCard(
          'Park Hyatt Tokyo',
          'Tokyo, Japan',
          '₹23,240',
          '5 Stars',
          'Business',
          Icons.hotel,
        ),
        const SizedBox(height: 12),
        _buildHotelDealCard(
          'Burj Al Arab',
          'Dubai, UAE',
          '₹37,350',
          '5 Stars',
          'Luxury',
          Icons.hotel,
        ),
        const SizedBox(height: 12),
        _buildHotelDealCard(
          'The Plaza New York',
          'New York, USA',
          '₹31,540',
          '5 Stars',
          'Historic',
          Icons.hotel,
        ),
      ],
    );
  }

  Widget _buildHotelDealCard(String hotelName, String location, String price, String rating, String category, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotelName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        rating,
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'per night',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _searchHotels() {
    // Show search results or navigate to results page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Searching for hotels...'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
