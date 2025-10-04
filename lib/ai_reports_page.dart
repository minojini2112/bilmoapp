import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AIReportsPage extends StatelessWidget {
  final List<Map<String, dynamic>> reports;
  final String product;
  
  const AIReportsPage({
    super.key, 
    required this.reports,
    required this.product,
  });

  // Fallback sample data if no API data
  static const List<Map<String, dynamic>> fallbackReports = [
    {
      "id": "Report1",
      "title": "Amazon Renewed Premium iPhone 15 Pro Max Deals",
      "snippet": "Amazon is offering significant discounts on renewed premium iPhone 15 Pro Max models. For instance, an unlocked blue titanium 256GB model is available for \$829, which is \$570 less than its new price. Other colors are priced at \$839. The 1TB storage option in black titanium, originally \$1,599 new, is now \$872.42 in renewed premium condition, representing a saving of over \$726.",
      "url": "https://vertexaisearch.cloud.google.com/grounding-api-redirect/AUZIYQE1Ank4_-dBHWHWfExfBcYju2p6VEwuvUY2wDgdjco77el2EA8z2GpeLySCtRdThk9VZibuhF-OpLf9QJXO7JgQHo4O73B-UZeDLKLfSrpold-O6O4xFOVJpM9UPsewA3fV2zIlxAAzLiDRVwGE14OblV0RWE79lT1yCvYf3FalVcaLsKgHWl1wxise_h-PFwhQjUjSThFz095SMWyUUCbP2pYRzPXAbfRW3bs5og=="
    },
    {
      "id": "Report2",
      "title": "Apple Certified Refurbished iPhone 15 Pro Max",
      "snippet": "Apple's official refurbished store has unlocked iPhone 15 Pro Max models available with savings. A refurbished iPhone 15 Pro Max 512GB in various titanium colors (Black, White, Natural, Blue) is priced at \$1,019.00, saving buyers \$280.00 off the original price of \$1,299.00. The 1TB refurbished models are available for \$1,189.00, a saving of \$310.00 from their original \$1,499.00 price.",
      "url": "https://vertexaisearch.cloud.google.com/grounding-api-redirect/AUZIYQH1aP32hf7bPdmCBROIvkspyh7XanIhGg6cK6logYp5yWcr-bVfjKszJe0GDPOuvYq_-l0X1EAZx2A9xYRa-Mnx3KC4mebz1wp5btcYpC9prYPglxNLBj9VDqDbFd0pwiGerWwCIQYNBYorSvVUQh60m_bYNzxD8YA9"
    },
    {
      "id": "Report3",
      "title": "Back Market Refurbished iPhone 15 Pro Max Deals",
      "snippet": "Back Market offers unlocked refurbished iPhone 15 Pro Max devices in various conditions and storage options. A 256GB model can be found starting at \$704.00 for \"Fair\" condition, \$745.29 for \"Good,\" and \$751.00 for \"Excellent.\" The 512GB storage option starts at \$767.00, and the 1TB option is available from \$807.00.",
      "url": "https://vertexaisearch.cloud.google.com/grounding-api-redirect/AUZIYQHDV9-SFQGg6SzLbggTcReqD-IQmL_JeXBIQ1rvkJ8Biiv_UCLq941keQFjZZk39xp4RVg0R-qYFMhdGo9lQPgll6aE_E7nniWI3wmbFekpm1FlA83sEJsy4dtDAXWSIidVEy-gW4k5j73df-WQhQ=="
    }
  ];

  // Get reports to display (use API data or fallback)
  List<Map<String, dynamic>> get displayReports {
    if (reports.isNotEmpty) {
      return reports;
    }
    return fallbackReports;
  }

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
        title: Text(
          'AI Reports - $product',
          style: const TextStyle(
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
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.psychology,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AI-Powered Market Analysis',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${reports.length} reports generated',
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
            // Reports List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: displayReports.length,
                itemBuilder: (context, index) {
                  final report = displayReports[index];
                  return _buildReportCard(context, report, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, Map<String, dynamic> report, int index) {
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
          onTap: () => _launchUrl(report['url']),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Report ${index + 1}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.open_in_new,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Report Title
                Text(
                  report['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                // Report Snippet
                Text(
                  report['snippet'],
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
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'View Full Report',
                    style: TextStyle(
                      color: Colors.red,
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
