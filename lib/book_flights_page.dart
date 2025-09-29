import 'package:flutter/material.dart';

class BookTicketsPage extends StatefulWidget {
  const BookTicketsPage({super.key});

  @override
  State<BookTicketsPage> createState() => _BookTicketsPageState();
}

class _BookTicketsPageState extends State<BookTicketsPage> {
  final TextEditingController _fromController = TextEditingController(text: 'Mumbai');
  final TextEditingController _toController = TextEditingController(text: 'Delhi');
  final TextEditingController _departureController = TextEditingController(text: '2024-02-15');
  final TextEditingController _returnController = TextEditingController(text: '2024-02-22');
  final TextEditingController _passengersController = TextEditingController(text: '1');
  
  String _selectedTransportType = 'Flights';
  String _selectedClass = 'Economy';
  String _selectedTripType = 'Round Trip';
  
  final List<String> _transportTypes = ['Flights', 'Trains', 'Buses'];
  final List<String> _classes = ['Economy', 'Business', 'First Class'];
  final List<String> _tripTypes = ['One Way', 'Round Trip', 'Multi City'];

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
                      // Popular Destinations
                      _buildPopularDestinations(),
                      const SizedBox(height: 30),
                      // Flight Deals
                      _buildFlightDeals(),
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
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.confirmation_number, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          const Text(
            'Book Tickets',
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
            'Search Tickets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Transport Type
          _buildDropdown('Transport Type', _selectedTransportType, _transportTypes, (value) {
            setState(() => _selectedTransportType = value!);
          }),
          const SizedBox(height: 16),
          // Trip Type
          _buildDropdown('Trip Type', _selectedTripType, _tripTypes, (value) {
            setState(() => _selectedTripType = value!);
          }),
          const SizedBox(height: 16),
          // From and To
          Row(
            children: [
              Expanded(child: _buildTextField('From', _fromController, Icons.flight_takeoff)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('To', _toController, Icons.flight_land)),
            ],
          ),
          const SizedBox(height: 16),
          // Dates
          Row(
            children: [
              Expanded(child: _buildTextField('Departure', _departureController, Icons.calendar_today)),
              const SizedBox(width: 16),
              if (_selectedTripType == 'Round Trip')
                Expanded(child: _buildTextField('Return', _returnController, Icons.calendar_today)),
            ],
          ),
          const SizedBox(height: 16),
          // Passengers and Class
          Row(
            children: [
              Expanded(child: _buildTextField('Passengers', _passengersController, Icons.person)),
              const SizedBox(width: 16),
              Expanded(child: _buildDropdown('Class', _selectedClass, _classes, (value) {
                setState(() => _selectedClass = value!);
              })),
            ],
          ),
          const SizedBox(height: 24),
          // Search Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _searchTickets(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Search Tickets',
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

  Widget _buildPopularDestinations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Routes',
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
              _buildDestinationCard('Mumbai → Delhi', '🚄', '₹1,200'),
              const SizedBox(width: 12),
              _buildDestinationCard('Bangalore → Chennai', '🚌', '₹800'),
              const SizedBox(width: 12),
              _buildDestinationCard('Delhi → Mumbai', '✈️', '₹4,500'),
              const SizedBox(width: 12),
              _buildDestinationCard('Kolkata → Delhi', '🚄', '₹1,800'),
              const SizedBox(width: 12),
              _buildDestinationCard('Mumbai → Goa', '🚌', '₹1,200'),
              const SizedBox(width: 12),
              _buildDestinationCard('Chennai → Mumbai', '✈️', '₹5,800'),
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

  Widget _buildFlightDeals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Best Travel Deals',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTransportDealCard(
          'Mumbai → Delhi',
          'Rajdhani Express',
          '₹1,200',
          '16h 30m',
          'AC 2 Tier',
          Icons.train,
        ),
        const SizedBox(height: 12),
        _buildTransportDealCard(
          'Delhi → Mumbai',
          'IndiGo Airlines',
          '₹4,500',
          '2h 15m',
          'Direct',
          Icons.flight,
        ),
        const SizedBox(height: 12),
        _buildTransportDealCard(
          'Bangalore → Chennai',
          'RedBus',
          '₹800',
          '6h 30m',
          'Semi-Sleeper',
          Icons.directions_bus,
        ),
        const SizedBox(height: 12),
        _buildTransportDealCard(
          'Kolkata → Delhi',
          'Duronto Express',
          '₹1,800',
          '17h 30m',
          'AC 3 Tier',
          Icons.train,
        ),
      ],
    );
  }

  Widget _buildTransportDealCard(String route, String operator, String price, String duration, String type, IconData icon) {
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
                  route,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  operator,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      duration,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type,
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
                'per person',
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

  void _searchTickets() {
    // Show search results or navigate to results page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for $_selectedTransportType...'),
        backgroundColor: Colors.red,
      ),
    );
  }

}
