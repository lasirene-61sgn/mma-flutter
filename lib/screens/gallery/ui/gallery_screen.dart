import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../main.dart';
import '../model/gallery_model.dart';
import '../notifier/gallery_notifier.dart';
import 'gallery_video_player.dart';
import 'images_screen_view.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(galleryNotifierProvider.notifier).loadGallery();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<GalleryAlbum> get _albums {
    final state = ref.watch(galleryNotifierProvider);
    final colors = [
      MMPApp.maroon,
      MMPApp.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.teal
    ];
    return state.galleryList.asMap().entries.map((entry) {
      final index = entry.key;
      final model = entry.value;
      return GalleryAlbum(
        title: model.title.isNotEmpty ? model.title : 'Album ${model.id}',
        date: '${model.createdAt.day}/${model.createdAt.month}/${model.createdAt.year}',
        imageCount: model.imagePaths.length,
        coverColor: colors[index % colors.length],
        imagePaths: model.imagePaths,
        videoPaths: model.videoPaths,
      );
    }).toList();
  }

  List<VideoItem> get _videos {
    final state = ref.watch(galleryNotifierProvider);
    final colors = [
      MMPApp.maroon,
      MMPApp.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.teal
    ];
    List<VideoItem> vids = [];
    int colorIndex = 0;
    for (var model in state.galleryList) {
      for (var url in model.videoPaths) {
        vids.add(VideoItem(
          title: model.title.isNotEmpty ? model.title : 'Video',
          duration: 'Play',
          color: colors[colorIndex % colors.length],
          videoUrl: url,
        ));
        colorIndex++;
      }
    }
    return vids;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galleryNotifierProvider);

    return Scaffold(
      backgroundColor: MMPApp.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Gallery",style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20
        ),),
        leading:IconButton(onPressed: (){Get.back();}, icon: Icon(Icons.arrow_back_ios,color: Colors.black,)),
      ),
      body: state.isLoading && state.galleryList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header Stats
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [MMPApp.maroon, MMPApp.maroonLight],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildGalleryStat('${_albums.length}', 'Albums'),
                      Container(height: 40, width: 1, color: Colors.white24),
                      _buildGalleryStat(
                        '${_albums.fold(0, (sum, album) => sum + album.imageCount)}',
                        'Photos',
                      ),
                      Container(height: 40, width: 1, color: Colors.white24),
                      _buildGalleryStat('${_videos.length}', 'Videos'),
                    ],
                  ),
                ),
                // Tabs
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: MMPApp.maroon,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: MMPApp.maroon,
                    tabs: const [
                      Tab(text: 'Albums'),
                      Tab(text: 'Videos'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Content
                Expanded(
                  child: state.error != null
                      ? Center(child: Text(state.error!))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAlbumsGrid(),
                            _buildVideosGrid(),
                          ],
                        ),
                ),
              ],
            ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: const Text('Upload feature coming soon!'),
      //         backgroundColor: MMPApp.maroon,
      //         behavior: SnackBarBehavior.floating,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(10),
      //         ),
      //       ),
      //     );
      //   },
      //   backgroundColor: MMPApp.maroon,
      //   child: const Icon(Icons.add_a_photo, color: Colors.white),
      // ),
    );
  }

  Widget _buildGalleryStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumsGrid() {
    final albums = _albums;
    if (albums.isEmpty) {
      return const Center(child: Text('No albums found'));
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return _buildAlbumCard(album);
      },
    );
  }

  Widget _buildAlbumCard(GalleryAlbum album) {
    return InkWell(
      onTap: () {
        _showAlbumPhotos(album);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album Cover
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      album.coverColor,
                      album.coverColor.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    if (album.imagePaths.isNotEmpty)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Image.network(
                            album.imagePaths.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.photo_library,
                                size: 50,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Icon(
                          Icons.photo_library,
                          size: 50,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${album.imageCount}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Album Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    album.date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosGrid() {
    final videos = _videos;
    if (videos.isEmpty) {
      return const Center(child: Text('No videos found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return InkWell(
          onTap: () {
            _showMediaSlider(video.videoUrl, true);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
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
              children: [
                // Thumbnail
                Container(
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [video.color, video.color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_fill,
                        size: 40,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            video.duration,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Watch Video',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.play_arrow, color: Colors.grey[400]),
                  onPressed: () {
                    _showMediaSlider(video.videoUrl, true);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAlbumPhotos(GalleryAlbum album) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: album.coverColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: album.coverColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${album.imageCount} photos • ${album.date}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagesScreenView(
                            images: album.imagePaths,
                            videos: album.videoPaths,
                            title: album.title,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Photos Grid
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: album.imagePaths.length,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    _showMediaSlider(album.imagePaths[index], false);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: album.coverColor.withValues(
                        alpha: 0.1 + (index % 5) * 0.1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        album.imagePaths[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image,
                          color: album.coverColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaSlider(String mediaUrl, bool isVideo) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            width: double.infinity,
            child: Stack(
              children: [
                isVideo
                    ? GalleryVideoPlayer(videoUrl: mediaUrl)
                    : Image.network(
                        mediaUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                if (!isVideo)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GalleryAlbum {
  final String title;
  final String date;
  final int imageCount;
  final Color coverColor;
  final List<String> imagePaths;
  final List<String> videoPaths;

  GalleryAlbum({
    required this.title,
    required this.date,
    required this.imageCount,
    required this.coverColor,
    required this.imagePaths,
    required this.videoPaths,
  });
}

class VideoItem {
  final String title;
  final String duration;
  final Color color;
  final String videoUrl;

  VideoItem({
    required this.title,
    required this.duration,
    required this.color,
    required this.videoUrl,
  });
}
