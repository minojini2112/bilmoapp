import 'package:flutter/material.dart';
import 'package:youtube_shorts/youtube_shorts.dart';
import 'youtube_api_service.dart';
import 'models/video_model.dart';

class YouTubeShortsScreen extends StatefulWidget {
  final String searchQuery;
  
  const YouTubeShortsScreen({super.key, required this.searchQuery});

  @override
  State<YouTubeShortsScreen> createState() => _YouTubeShortsScreenState();
}

class _YouTubeShortsScreenState extends State<YouTubeShortsScreen> {
  List<VideoModel> shorts = [];
  List<String> shortsUrls = [];
  bool isLoading = true;
  String? errorMessage;
  late VideosSourceController _videosSourceController;

  @override
  void initState() {
    super.initState();
    _videosSourceController = VideosSourceController();
    _loadShorts();
  }

  @override
  void dispose() {
    _videosSourceController.dispose();
    super.dispose();
  }

  Future<void> _loadShorts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('🎬 Loading YouTube Shorts for: ${widget.searchQuery}');
      final results = await YouTubeApiService.searchShortsNew(widget.searchQuery);
      
      setState(() {
        shorts = results;
        shortsUrls = results.map((video) => video.shortsUrl).toList();
        isLoading = false;
      });
      
      print('✅ Loaded ${shorts.length} YouTube Shorts');
    } catch (e) {
      print('❌ Error loading shorts: $e');
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }
    
    if (errorMessage != null) {
      return _buildErrorState();
    }
    
    if (shorts.isEmpty) {
      return _buildEmptyState();
    }
    
    return _buildShortsView();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading YouTube Shorts...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Searching for "${widget.searchQuery}"',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load YouTube Shorts',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage ?? 'Unknown error occurred',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadShorts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              color: Colors.white.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              'No YouTube Shorts Found',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Try searching for a different product',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadShorts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Search Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortsView() {
    return Stack(
      children: [
        // YouTube Shorts Player
        YoutubeShorts(
          shortsUrlsList: shortsUrls,
          videosSourceController: _videosSourceController,
          onVideoIndexChanged: (index) {
            print('📺 Now playing video at index: $index');
            // You can add additional logic here when video changes
          },
          onVideoEnd: (index) {
            print('🏁 Video $index ended');
            // You can add logic here when a video ends
          },
          onVideoError: (error) {
            print('❌ Video error: $error');
            // Handle video errors
          },
        ),
        
        // Top Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Reels for "${widget.searchQuery}"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadShorts,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Video Info Overlay (Optional - can be customized)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: _buildVideoInfo(),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoInfo() {
    // Get current video info based on the current index
    // Note: You might need to track the current video index from the YoutubeShorts widget
    if (shorts.isEmpty) return const SizedBox.shrink();
    
    // For now, show general info
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${shorts.length} Shorts Available',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Swipe up/down to navigate',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.play_circle_outline,
              color: Colors.red,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Tap to play/pause',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
