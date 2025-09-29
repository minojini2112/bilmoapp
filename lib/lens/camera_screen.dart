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
      appBar: AppBar(
        title: const Text('Bilmo Lens'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Camera Preview
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
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
                  backgroundColor: Colors.blue[700],
                  child: const Icon(Icons.photo_library, color: Colors.white),
                ),
                
                // Capture button
                FloatingActionButton.extended(
                  heroTag: "capture",
                  onPressed: _isLoading ? null : _captureAndAnalyze,
                  backgroundColor: Colors.red[600],
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
                  backgroundColor: Colors.green[600],
                  child: const Icon(Icons.info, color: Colors.white),
                ),
              ],
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
          title: const Text('How to use'),
          content: const Text(
            '1. Point camera at a product\n'
            '2. Tap "Capture & Analyze" to take photo\n'
            '3. Or tap gallery icon to select existing photo\n'
            '4. Bilmo Lens will identify the product and show similar items from Indian e-commerce sites',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
