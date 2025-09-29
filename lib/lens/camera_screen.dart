import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'services/product_recognition_service.dart';
import 'models/product_response.dart';
import 'screens/product_results_screen.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final ImagePicker _picker = ImagePicker();
  final ProductRecognitionService _productService = ProductRecognitionService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize the camera controller
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureAndAnalyze() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Ensure the camera is initialized
      await _initializeControllerFuture;

      // Take the picture
      final image = await _controller.takePicture();
      final imageFile = File(image.path);

      // Analyze the image
      await _analyzeImage(imageFile);

    } catch (e) {
      _showErrorDialog('Error capturing image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        final imageFile = File(image.path);
        await _analyzeImage(imageFile);
      }

    } catch (e) {
      _showErrorDialog('Error selecting image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    try {
      final ProductResponse response = await _productService.analyzeProduct(imageFile);
      
      if (!mounted) return;
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProductResultsScreen(
            productResponse: response,
            imageFile: imageFile,
          ),
        ),
      );

    } catch (e) {
      _showErrorDialog('Error analyzing image: $e');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
              _buildHeader(),
              // Camera content
              Expanded(
                        child: Stack(
                  children: [
                    // Camera Preview
                    FutureBuilder<void>(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return CameraPreview(_controller);
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }
                      },
                    ),
                    
                    // Loading overlay
                    if (_isLoading)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Bilmo Lens analyzing...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Control buttons
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Gallery button
                          FloatingActionButton(
                            heroTag: "gallery",
                            onPressed: _isLoading ? null : _pickFromGallery,
                            backgroundColor: Colors.red,
                            child: const Icon(Icons.photo_library, color: Colors.white),
                          ),
                          
                          // Capture button
                          FloatingActionButton.extended(
                            heroTag: "capture",
                            onPressed: _isLoading ? null : _captureAndAnalyze,
                            backgroundColor: Colors.red,
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            label: const Text(
                              'Capture & Analyze',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          
                          // Info button
                          FloatingActionButton(
                            heroTag: "info",
                            onPressed: () => _showInfoDialog(),
                            backgroundColor: Colors.orange,
                            child: const Icon(Icons.info, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
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
          const Icon(Icons.camera_alt, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          const Text(
            'Bilmo Lens',
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

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text(
            'How to use',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '1. Point camera at a product\n'
            '2. Tap "Capture & Analyze" to take photo\n'
            '3. Or tap gallery icon to select existing photo\n'
            '4. Bilmo Lens will identify the product and show similar items from Indian e-commerce sites',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Got it',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
