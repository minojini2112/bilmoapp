import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'youtube_api_service.dart';

class YouTubeReelsPage extends StatefulWidget {
  final String searchQuery;
  
  const YouTubeReelsPage({super.key, required this.searchQuery});

  @override
  State<YouTubeReelsPage> createState() => _YouTubeReelsPageState();
}

class _YouTubeReelsPageState extends State<YouTubeReelsPage> {
  List<Map<String, dynamic>> shorts = [];
  bool isLoading = true;
  String? errorMessage;
  final ScrollController _scrollController = ScrollController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadShorts();
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reels for "${widget.searchQuery}"',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadShorts,
          ),
        ],
      ),
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
    
    return _buildShortsList();
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
              'Try searching for a different product or check your internet connection',
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

  Widget _buildShortsList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: shorts.length,
      itemBuilder: (context, index) {
        final short = shorts[index];
        return _buildShortCard(short, index);
      },
    );
  }

  Widget _buildShortCard(Map<String, dynamic> short, int index) {
    final title = short['title'] ?? 'Untitled';
    final thumbnail = short['thumbnail'] ?? '';
    final channelTitle = short['channelTitle'] ?? 'Unknown Channel';
    final viewCount = short['viewCount'] ?? '';
    final likeCount = short['likeCount'] ?? '';
    final duration = short['duration'] ?? '';
    final url = short['url'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail and Play Button
          GestureDetector(
            onTap: () => _launchVideo(url),
            child: Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    color: Colors.grey[800],
                  ),
                  child: thumbnail.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.network(
                            thumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[800],
                                child: Icon(
                                  Icons.video_library,
                                  color: Colors.white.withOpacity(0.5),
                                  size: 48,
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: Icon(
                            Icons.video_library,
                            color: Colors.white.withOpacity(0.5),
                            size: 48,
                          ),
                        ),
                ),
                // Play Button Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                // Duration Badge
                if (duration.isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        duration,
                        style: const TextStyle(
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
          
          // Video Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                
                // Channel Name
                Text(
                  channelTitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Stats Row
                Row(
                  children: [
                    if (viewCount.isNotEmpty) ...[
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
                      const SizedBox(width: 16),
                    ],
                    if (likeCount.isNotEmpty) ...[
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
                const SizedBox(height: 12),
                
                // Watch Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchVideo(url),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Watch on YouTube'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchVideo(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video URL not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
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
}
