import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'youtube_api_service.dart';

class YouTubeReelsPlayerPage extends StatefulWidget {
  final String searchQuery;
  
  const YouTubeReelsPlayerPage({super.key, required this.searchQuery});

  @override
  State<YouTubeReelsPlayerPage> createState() => _YouTubeReelsPlayerPageState();
}

class _YouTubeReelsPlayerPageState extends State<YouTubeReelsPlayerPage> {
  List<Map<String, dynamic>> shorts = [];
  bool isLoading = true;
  String? errorMessage;
  int currentIndex = 0;
  late PageController _pageController;
  List<YoutubePlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadShorts();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
      
      // Initialize YouTube controllers for each video
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
        final controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            isLive: false,
            forceHD: true,
            enableCaption: false,
            showLiveFullscreenButton: false,
            hideControls: true,
            hideThumbnail: true,
            useHybridComposition: true,
          ),
        );
        _controllers.add(controller);
      } else {
        _controllers.add(YoutubePlayerController(
          initialVideoId: '',
          flags: const YoutubePlayerFlags(),
        ));
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
    
    // Pause all other videos
    for (int i = 0; i < _controllers.length; i++) {
      if (i != index && _controllers[i].value.isReady) {
        _controllers[i].pause();
      }
    }
    
    // Auto-play current video
    if (index < _controllers.length && _controllers[index].value.isReady) {
      _controllers[index].play();
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
            return _buildVideoPlayer(index);
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
        
        // Video Controls
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              if (currentIndex < _controllers.length) {
                if (_controllers[currentIndex].value.isPlaying) {
                  _controllers[currentIndex].pause();
                } else {
                  _controllers[currentIndex].play();
                }
              }
            },
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _controllers.isNotEmpty && 
                          currentIndex < _controllers.length && 
                          _controllers[currentIndex].value.isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
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
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer(int index) {
    if (index >= shorts.length || index >= _controllers.length) {
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

    if (videoId.isEmpty) {
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

    return Container(
      color: Colors.black,
      child: YoutubePlayer(
        controller: _controllers[index],
        showVideoProgressIndicator: false,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
        ),
        onReady: () {
          print('✅ Video $index is ready');
        },
        onEnded: (metaData) {
          print('🏁 Video $index ended');
          // Auto-play next video
          if (index < shorts.length - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
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
        
        // Video Counter
        const SizedBox(height: 8),
        Text(
          '${currentIndex + 1} of ${shorts.length}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
