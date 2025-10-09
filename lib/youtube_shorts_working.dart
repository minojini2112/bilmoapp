import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'youtube_api_service.dart';
import 'models/video_model.dart';

class YouTubeShortsWorking extends StatefulWidget {
  final String searchQuery;
  
  const YouTubeShortsWorking({super.key, required this.searchQuery});

  @override
  State<YouTubeShortsWorking> createState() => _YouTubeShortsWorkingState();
}

class _YouTubeShortsWorkingState extends State<YouTubeShortsWorking> {
  List<VideoModel> shorts = [];
  bool isLoading = true;
  String? errorMessage;
  int currentIndex = 0;
  late PageController _pageController;
  List<YoutubePlayerController> _controllers = [];
  double? _dragStartDy;

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
      final results = await YouTubeApiService.searchShortsNew(widget.searchQuery);
      
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


  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
    
    // Pause all other videos
    for (int i = 0; i < _controllers.length; i++) {
      if (i != index) {
        _controllers[i].pause();
      }
    }

    // Aggressively start playback of the current video
    if (index < _controllers.length) {
      // Ensure correct video is cued then played
      final controller = _controllers[index];
      controller.seekTo(const Duration(seconds: 0));
      controller.play();
      // Try again after the frame is rendered (helps if controller isn't ready yet)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.play();
      });
    }
  }

  void _initializeControllers() {
    _controllers.clear();
    for (int i = 0; i < shorts.length; i++) {
      final videoId = shorts[i].videoId;
      if (videoId.isNotEmpty) {
        final controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: i == 0, // Auto-play first video
            mute: false,
            isLive: false,
            forceHD: true,
            enableCaption: false,
            showLiveFullscreenButton: false,
            hideControls: true,
            hideThumbnail: true,
            useHybridComposition: true,
            loop: false,
          ),
        );
        _controllers.add(controller);
        
        // Auto-play first video when ready
        if (i == 0) {
          controller.addListener(() {
            if (controller.value.isReady && !controller.value.isPlaying) {
              controller.play();
            }
          });
        }
      } else {
        _controllers.add(YoutubePlayerController(
          initialVideoId: '',
          flags: const YoutubePlayerFlags(),
        ));
      }
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
        // Video Player with smooth scrolling
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          pageSnapping: true,
          onPageChanged: _onPageChanged,
          itemCount: shorts.length,
          // Use page physics for a crisp, smooth snap between videos
          physics: const PageScrollPhysics(),
          itemBuilder: (context, index) {
            return _buildVideoPlayer(index);
          },
        ),
        
        // Professional Top Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Back Button with modern design
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Title with better typography
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reels',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'for "${widget.searchQuery}"',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Refresh Button with modern design
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                      onPressed: _loadShorts,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Professional Video Info Overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
            child: _buildVideoInfo(),
          ),
        ),
        
        // Tap anywhere to toggle play/pause (no visible button)
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
            onVerticalDragStart: (details) {
              _dragStartDy = details.globalPosition.dy;
            },
            onVerticalDragEnd: (details) {
              if (_dragStartDy == null) return;
              // Determine swipe direction and navigate
              final dy = details.velocity.pixelsPerSecond.dy;
              // If swipe up (negative dy), go to next; if swipe down, go to previous
              if (dy < -200) {
                if (currentIndex < shorts.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                  );
                }
              } else if (dy > 200) {
                if (currentIndex > 0) {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                  );
                }
              }
              _dragStartDy = null;
            },
            child: const SizedBox.expand(),
          ),
        ),
        
        // Video Progress Indicator
        Positioned(
          right: 16,
          top: 0,
          bottom: 0,
          child: Center(
            child: _buildVideoProgress(),
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
    final videoId = short.videoId;

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

    final controller = _controllers[index];
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: false,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
        ),
        onReady: () {
          // If this is the current page, ensure it plays
          if (index == currentIndex) {
            controller.play();
          }
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
      builder: (context, player) {
        return Container(
          color: Colors.black,
          child: player,
        );
      },
    );
  }

  Widget _buildVideoInfo() {
    if (currentIndex >= shorts.length) {
      return const SizedBox.shrink();
    }

    final short = shorts[currentIndex];
    final title = short.title;
    final channelTitle = short.channelTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Video Counter with modern design
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            '${currentIndex + 1} of ${shorts.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Title with better typography
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.2,
            letterSpacing: 0.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        
        // Channel with modern design
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              channelTitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoProgress() {
    if (currentIndex >= _controllers.length) {
      return const SizedBox.shrink();
    }

    final controller = _controllers[currentIndex];
    if (!controller.value.isReady) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 4,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Stack(
        children: [
          // Progress bar - simplified without duration dependency
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              // Use a simple progress indicator based on position
              final position = controller.value.position.inMilliseconds;
              final progress = position > 0 ? (position / 30000).clamp(0.0, 1.0) : 0.0; // Assume 30s max
              
              return Container(
                width: 4,
                height: 200 * progress,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
