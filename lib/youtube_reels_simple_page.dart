import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'youtube_api_service.dart';

class YouTubeReelsSimplePage extends StatefulWidget {
  final String searchQuery;
  
  const YouTubeReelsSimplePage({super.key, required this.searchQuery});

  @override
  State<YouTubeReelsSimplePage> createState() => _YouTubeReelsSimplePageState();
}

class _YouTubeReelsSimplePageState extends State<YouTubeReelsSimplePage> {
  List<Map<String, dynamic>> shorts = [];
  bool isLoading = true;
  String? errorMessage;
  int currentIndex = 0;
  late PageController _pageController;
  List<VideoPlayerController> _controllers = [];
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadShorts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _chewieController?.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadShorts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('🎬 Loading YouTube Shorts for: ${widget.searchQuery}');
      final results = await YouTubeApiService.searchShorts(widget.searchQuery);
      
      setState(() {
        shorts = results;
        isLoading = false;
      });
      
      // Initialize video controllers for each video
      _initializeControllers();
      
      print('✅ Loaded ${shorts.length} YouTube Shorts');
    } catch (e) {
      print('❌ Error loading shorts: $e');
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  void _initializeControllers() {
    _controllers.clear();
    for (int i = 0; i < shorts.length; i++) {
      final videoId = shorts[i]['id'] ?? '';
      if (videoId.isNotEmpty) {
        // For now, we'll use thumbnail images and launch YouTube on tap
        // This avoids the namespace issues with youtube_player_flutter
        final controller = VideoPlayerController.networkUrl(
          Uri.parse('https://www.youtube.com/watch?v=$videoId'),
        );
        _controllers.add(controller);
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
    
    // Pause all other videos
    for (int i = 0; i < _controllers.length; i++) {
      if (i != index && _controllers[i].value.isInitialized) {
        _controllers[i].pause();
      }
    }
  }

  Future<void> _launchVideo(String videoId) async {
    final url = 'https://www.youtube.com/shorts/$videoId';
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot open video'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening video: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
    
    return _buildReelsView();
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

  Widget _buildReelsView() {
    return Stack(
      children: [
        // Video Player
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: _onPageChanged,
          itemCount: shorts.length,
          itemBuilder: (context, index) {
            return _buildVideoCard(index);
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
        
        // Video Info Overlay
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

  Widget _buildVideoCard(int index) {
    if (index >= shorts.length) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Video not available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final short = shorts[index];
    final videoId = short['id'] ?? '';
    final thumbnail = short['thumbnail'] ?? '';

    return GestureDetector(
      onTap: () => _launchVideo(videoId),
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Thumbnail Image
            if (thumbnail.isNotEmpty)
              Image.network(
                thumbnail,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(
                        Icons.video_library,
                        color: Colors.white54,
                        size: 64,
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(
                    Icons.video_library,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              ),
            
            // Play Button Overlay
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
            
            // YouTube Logo
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'YouTube',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    if (currentIndex >= shorts.length) {
      return const SizedBox.shrink();
    }

    final short = shorts[currentIndex];
    final title = short['title'] ?? 'Untitled';
    final channelTitle = short['channelTitle'] ?? 'Unknown Channel';
    final viewCount = short['viewCount'] ?? '';
    final likeCount = short['likeCount'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        
        // Channel and Stats
        Row(
          children: [
            Text(
              channelTitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            if (viewCount.isNotEmpty) ...[
              const SizedBox(width: 16),
              Icon(
                Icons.visibility,
                color: Colors.white.withOpacity(0.6),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                viewCount,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
            if (likeCount.isNotEmpty) ...[
              const SizedBox(width: 16),
              Icon(
                Icons.thumb_up,
                color: Colors.white.withOpacity(0.6),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                likeCount,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        
        // Video Counter and Tap Hint
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${currentIndex + 1} of ${shorts.length}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Tap to watch on YouTube',
              style: TextStyle(
                color: Colors.red.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
