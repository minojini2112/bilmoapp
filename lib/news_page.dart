import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  // Sample data - will be replaced with API call later
  final List<Map<String, dynamic>> news = const [
    {
      "id": "News1",
      "title": "Trends in iPhone 15 Pro Max Deals",
      "snippet": "The best deals for the iPhone 15 Pro Max often involve trading in an older device and signing up for unlimited plans with major carriers. While this trend continues, some carriers like Verizon have recently introduced discounts that do not require a trade-in. Additionally, prepaid options are available for those looking to avoid expensive unlimited postpaid plans, though these typically require a larger upfront payment.",
      "url": "https://vertexaisearch.cloud.google.com/grounding-api-redirect/AUZIYQHNC72-MDirbziw7uRiisklqdV_iujwv_s9BNpBVbVCYMikhNNACvJnWBjD-pWIIhFaCiDFd4Mp1TBoWS7PElYg1pCJ19j7lK8qHlhNVNCNNvxmfMkCNSwgRVW_0Q9l5nd4tZiKmrWN7lIQiXhoz7VYAU6L8ROws1wHkyDfHA8="
    },
    {
      "id": "News2",
      "title": "AT&T Offers for iPhone 15 Pro Max",
      "snippet": "AT&T is providing various incentives for the iPhone 15 Pro Max, including offers like getting four lines of unlimited service for \$25 per month per line. Online-only deals include \$200 off a new line and up to \$800 per line for customers looking to switch and break their current contract.",
      "url": "https://vertexaisearch.cloud.google.com/grounding-api-redirect/AUZIYQHy898o-biMJYRyyEZeMSCCUyZ7ptUSMnrOR38pm2vx5JeQGBRxIBiQUxHQSKYaTWopQeDg5i_j4Kn_ibISJl60TDqmWzm1OrMpg3eZW5cNqVm1-sBQ-EdCDCdUtj4kHRtlgKhFVkKZwVJuRvXGTqYmmarrqAA="
    },
    {
      "id": "News3",
      "title": "Carrier Availability and Discounts for iPhone 15 Pro Max",
      "snippet": "As of September 2025, major carriers like Verizon and T-Mobile primarily offer used or refurbished iPhone 15 Pro Max models. Verizon provides significant savings on these models when adding a new line on an Unlimited Welcome, Plus, or Ultimate plan, with discounts applied as monthly bill credits over 36 months. T-Mobile also has promotions, often requiring trade-ins or new lines to get substantial discounts on iPhone models.",
      "url": "https://vertexaisearch.cloud.google.com/grounding-api-redirect/AUZIYQFR5Io4eE8t4MqOTYWNCGktWUo4MP4_bV7X2Lw11SgXqHpR7NsiOQ-PdsrUu4MPWfnBTjOrwakUrTrJw_fUkqtsJ9FYD0BNd2kgcJB43c1EZXprTuj2ni_fUr_v55u4-3FDKFQixpfMIi1T"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Market News',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // TODO: Add refresh functionality
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D1B69), // Deep purple
              Color(0xFF1A1A2E), // Dark blue
              Colors.black, // Black at bottom
            ],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.newspaper,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Latest Market Updates',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${news.length} articles available',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
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
            // News List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: news.length,
                itemBuilder: (context, index) {
                  final article = news[index];
                  return _buildNewsCard(context, article, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, Map<String, dynamic> article, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _launchUrl(article['url']),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // News Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Article ${index + 1}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.open_in_new,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // News Title
                Text(
                  article['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                // News Snippet
                Text(
                  article['snippet'],
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // Action Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Read Full Article',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
