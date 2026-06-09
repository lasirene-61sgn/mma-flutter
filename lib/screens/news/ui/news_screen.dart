import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../notifier/news_notifier.dart';
import 'package:intl/intl.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
        ref.read(newsNotifierProvider.notifier).loadNews();

    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsNotifierProvider);
    return Scaffold(
      backgroundColor: MMPApp.cream,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured News
            // Container(
            //   width: double.infinity,
            //   margin: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     gradient: const LinearGradient(
            //       colors: [MMPApp.maroon, MMPApp.maroonLight],
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //     ),
            //     borderRadius: BorderRadius.circular(20),
            //     boxShadow: [
            //       BoxShadow(
            //         color: MMPApp.maroon.withValues(alpha: 0.3),
            //         blurRadius: 15,
            //         offset: const Offset(0, 5),
            //       ),
            //     ],
            //   ),
            //   child: Stack(
            //     children: [
            //       Positioned(
            //         right: -20,
            //         bottom: -20,
            //         child: Icon(
            //           Icons.newspaper,
            //           size: 120,
            //           color: Colors.white.withValues(alpha: 0.1),
            //         ),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.all(20),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Container(
            //               padding: const EdgeInsets.symmetric(
            //                 horizontal: 10,
            //                 vertical: 4,
            //               ),
            //               decoration: BoxDecoration(
            //                 color: MMPApp.orange,
            //                 borderRadius: BorderRadius.circular(20),
            //               ),
            //               child: const Text(
            //                 'BREAKING',
            //                 style: TextStyle(
            //                   fontSize: 10,
            //                   fontWeight: FontWeight.bold,
            //                   color: Colors.white,
            //                 ),
            //               ),
            //             ),
            //             const SizedBox(height: 12),
            //             const Text(
            //               'MMP Launches New Youth Leadership Program 2025',
            //               style: TextStyle(
            //                 fontSize: 20,
            //                 fontWeight: FontWeight.bold,
            //                 color: Colors.white,
            //               ),
            //             ),
            //             const SizedBox(height: 8),
            //             Text(
            //               'A comprehensive initiative to train and empower young leaders across India with workshops, mentorship, and real-world projects.',
            //               style: TextStyle(
            //                 fontSize: 14,
            //                 color: Colors.white.withValues(alpha: 0.9),
            //                 height: 1.4,
            //               ),
            //             ),
            //             const SizedBox(height: 16),
            //             Row(
            //               children: [
            //                 Icon(
            //                   Icons.access_time,
            //                   size: 14,
            //                   color: Colors.white.withValues(alpha: 0.7),
            //                 ),
            //                 const SizedBox(width: 4),
            //                 Text(
            //                   '2 hours ago',
            //                   style: TextStyle(
            //                     fontSize: 12,
            //                     color: Colors.white.withValues(alpha: 0.7),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Categories
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: SingleChildScrollView(
            //     scrollDirection: Axis.horizontal,
            //     child: Row(
            //       children: [
            //         _buildCategoryChip('All', true),
            //         _buildCategoryChip('Announcements', false),
            //         _buildCategoryChip('Events', false),
            //         _buildCategoryChip('Achievements', false),
            //         _buildCategoryChip('Updates', false),
            //       ],
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 16),
            // News List

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Latest News',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MMPApp.maroon,
                    ),
                  ),
                  if (state.isLoading && state.newsList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: MMPApp.maroon)),
                    )
                  else if (state.newsList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No news available',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    )
                  else
                    ...state.newsList.map((news) {
                      final imageUrl = news.imagePath.isNotEmpty ? news.imagePath : null;
                      return _buildNewsItem(
                        news.title,
                        news.summary.isNotEmpty ? news.summary : 'Read more...',
                        DateFormat('dd MMM yyyy').format(news.postedDate),
                        'News', // You can use news.author or status here if desired
                        Icons.description,
                        MMPApp.maroon,
                        imageUrl: imageUrl,
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: const Text('Submit news feature coming soon!'),
      //         backgroundColor: MMPApp.maroon,
      //         behavior: SnackBarBehavior.floating,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(10),
      //         ),
      //       ),
      //     );
      //   },
      //   backgroundColor: MMPApp.maroon,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
    );
  }



  Widget _buildNewsItem(
    String title,
    String excerpt,
    String time,
    String category,
    IconData icon,
    Color color, {
    String? imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: imageUrl != null && imageUrl.isNotEmpty ? () => _showFullImage(imageUrl) : null,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                image: imageUrl != null && imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null || imageUrl.isEmpty
                  ? Icon(icon, color: color, size: 28)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  excerpt,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Row(
                //   children: [
                //     Icon(Icons.remove_red_eye, size: 14, color: Colors.grey[400]),
                //     const SizedBox(width: 4),
                //     Text(
                //       '234 views',
                //       style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                //     ),
                //     const SizedBox(width: 16),
                //     Icon(Icons.share, size: 14, color: Colors.grey[400]),
                //     const SizedBox(width: 4),
                //     Text(
                //       'Share',
                //       style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, color: Colors.white, size: 50),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
