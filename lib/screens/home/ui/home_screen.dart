import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:mmp_official/main.dart';
import 'package:mmp_official/screens/dashboard/ui/birthday_screen.dart';
import 'package:mmp_official/screens/dashboard/ui/anniversary.dart';
import 'package:mmp_official/service/route/route_name.dart';
import 'dart:async';
import '../../dashboard/ui/dashboard_screen.dart';
import '../../gallery/ui/gallery_screen.dart';
import '../../dashboard/notifier/dashboard_notifier.dart';
import '../../dashboard/model/banner_model.dart';
import '../../events/notifier/events_notifier.dart';
import '../../news/notifier/news_notifier.dart';
import '../../profile/notifier/profile_notifier.dart';
import '../../profile/ui/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;


  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    
    Future.microtask(() {
      final notifier = ref.read(dashboardNotifierProvider.notifier);
      notifier.loadBanner();
      notifier.loadBirthdays();
      notifier.loadAnniversaries();
      notifier.loadNotification();
      notifier.loadDonate();
      notifier.loadSocialLinks();
      notifier.loadDashboardCounters();
      ref.read(eventsNotifierProvider.notifier).loadEvents();
      ref.read(newsNotifierProvider.notifier).loadNews();
      ref.read(profileNotifierProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();

    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final banners = ref.read(dashboardNotifierProvider).banners;
        if (banners.isEmpty) return;
        int nextPage = (_currentPage + 1) % banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final eventsState = ref.watch(eventsNotifierProvider);
    final newsState = ref.watch(newsNotifierProvider);
    final profileState = ref.watch(profileNotifierProvider);

    final banners = dashboardState.banners;

    // Static data for UI testing if the list is empty
    // if (apiBirthdays.isEmpty) {
    //   apiBirthdays = [
    //     CelebrationData('Rahul Sharma', 'Today', 'assets/images/mmp_logo.jpeg', 'Delhi Chapter'),
    //     CelebrationData('Rahul Sharma', 'Today', 'assets/images/mmp_logo.jpeg', 'Delhi Chapter'),
    //     CelebrationData('Rahul Sharma', 'Today', 'assets/images/mmp_logo.jpeg', 'Delhi Chapter'),
    //     CelebrationData('Rahul Sharma', 'Today', 'assets/images/mmp_logo.jpeg', 'Delhi Chapter'),
    //     CelebrationData('Rahul Sharma', 'Today', 'assets/images/mmp_logo.jpeg', 'Delhi Chapter'),
    //     CelebrationData('Priya Singh', 'Today', 'assets/images/mmp_logo.jpeg', 'Mumbai Chapter'),
    //   ];
    // }

    final dashboardEvents = eventsState.upcomingEvents.take(2).toList();
    final dashboardNews = newsState.newsList.take(2).toList();

    return Scaffold(
      backgroundColor: MMPApp.cream,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ad Slider Banner
            if (banners.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.all(16),
                height: 180,
                child: Stack(
                children: [
                  // PageView for slides
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemCount: banners.length,
                      itemBuilder: (context, index) {
                        return _buildBannerSlide(banners[index]);
                      },
                    ),
                  ),
                  // Page Indicators
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        banners.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ],
            
            // Profile Summary Row
            if (profileState.profile != null)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: MMPApp.maroon.withValues(alpha: 0.1),
                        backgroundImage: profileState.profile!.image != null && profileState.profile!.image!.isNotEmpty
                            ? NetworkImage(profileState.profile!.image!)
                            : null,
                        child: profileState.profile!.image == null || profileState.profile!.image!.isEmpty
                            ? const Icon(Icons.person, color: MMPApp.maroon)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (profileState.profile!.labelName != null && profileState.profile!.labelName!.isNotEmpty)
                                  ? profileState.profile!.labelName!
                                  : profileState.profile!.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'View',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            
            // Birthday & Anniversary Tabs Section Removed
            
            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.event,
                          title: 'Events',
                          subtitle: 'Activities',
                          color: MMPApp.orange,
                          badgeCount: dashboardState.dashboardCounters?.newEventCount ?? 0,
                          onTap: () => _navigateToTab(context, 1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.people,
                          title: 'Members',
                          subtitle: 'Our Members',
                          color: MMPApp.maroon,
                          badgeCount: dashboardState.dashboardCounters?.newCustomerCount ?? 0,
                          onTap: () => _navigateToTab(context, 4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.photo_library,
                          title: 'Gallery',
                          subtitle: 'Photo memories',
                          color: Colors.blue,
                          badgeCount: dashboardState.dashboardCounters?.newGalleryCount ?? 0,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const GalleryScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.stars,
                          title: 'Team',
                          subtitle: 'Our Team',
                          color: MMPApp.gold,
                          badgeCount: dashboardState.dashboardCounters?.newCommitteeCount ?? 0,
                          onTap: () => _navigateToTab(context, 3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.cake,
                          title: 'Birthdays',
                          subtitle: 'Today\'s Specials',
                          color: Colors.pink,
                          badgeCount: dashboardState.todayBirthdayCount,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const BirthdayScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.favorite,
                          title: 'Anniversaries',
                          subtitle: 'Celebrate Together',
                          color: Colors.redAccent,
                          badgeCount: dashboardState.todayAnniversaryCount,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AnniversaryScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 12),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: _buildQuickActionCard(
                  //         context,
                  //         icon: Icons.account_balance,
                  //         title: 'MMPCT',
                  //         subtitle: 'Mel Milaap Parivaar',
                  //         color: Colors.orange,
                  //         onTap: () {
                  //           Get.toNamed(RouteName.mmpct);
                  //         },
                  //       ),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     Expanded(
                  //       child: _buildQuickActionCard(
                  //         context,
                  //         icon: Icons.info,
                  //         title: 'About Us',
                  //         subtitle: 'Know more',
                  //         color: Colors.teal,
                  //         onTap: () {
                  //           final dashboardState = context.findAncestorStateOfType<DashboardScreenState>();
                  //           dashboardState?.showAboutDialog();
                  //         },
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Upcoming Events
            if (dashboardEvents.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Upcoming Events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: MMPApp.maroon,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _navigateToTab(context, 1),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...dashboardEvents.map((event) {
                      final dateStr = '${event.postedDate.day}/${event.postedDate.month}/${event.postedDate.year}';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildEventCard(
                          context,
                          event.name,
                          dateStr,
                          'TBD', // API does not provide a single location field
                          true,
                          imageUrl: event.imagePath.isNotEmpty 
                              ? event.imagePath 
                              : (event.imagePaths.isNotEmpty ? event.imagePaths.first : null),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Latest News
            if (dashboardNews.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Latest News',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: MMPApp.maroon,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _navigateToTab(context, 2),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...dashboardNews.map((news) {
                      final dateStr = '${news.postedDate.day}/${news.postedDate.month}/${news.postedDate.year}';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildNewsCard(
                          context,
                          news.title,
                          news.summary,
                          dateStr,
                          imageUrl: news.imagePath.isNotEmpty ? news.imagePath : null,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Donate Image Section
            if (dashboardState.donate?.imageUrl != null && dashboardState.donate!.imageUrl.isNotEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Donate Now',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: MMPApp.maroon,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 350),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            dashboardState.donate!.imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(30.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(30.0),
                                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
            
            // Our Values
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: MMPApp.borderBrown.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Our Core Values',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MMPApp.maroon,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildValueItem(Icons.groups, 'TOGETHER'),
                        _buildValueItem(Icons.emoji_events, 'TOWARDS'),
                        _buildValueItem(Icons.temple_hindu, 'TOMORROW'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Social Media Icons Row
            if (dashboardState.socialLinks != null &&
                (dashboardState.socialLinks!.facebookLink != null ||
                 dashboardState.socialLinks!.whatsappLink != null ||
                 dashboardState.socialLinks!.instagramLink != null ||
                 dashboardState.socialLinks!.linkedinLink != null ||
                 dashboardState.socialLinks!.emailLink != null ||
                 dashboardState.socialLinks!.twitterLink != null ||
                 dashboardState.socialLinks!.youtubeLink != null)) ...[
              Center(
                child: const Text(
                  'Connect with us',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Wrap(
                spacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  if (dashboardState.socialLinks!.facebookLink != null && dashboardState.socialLinks!.facebookLink!.isNotEmpty)
                    _buildSocialIcon(
                      icon: const FaIcon(FontAwesomeIcons.facebook, color: Color(0xFF1877F2), size: 24),
                      color: const Color(0xFF1877F2),
                      onTap: () => _launchURL(dashboardState.socialLinks!.facebookLink!),
                    ),
                  if (dashboardState.socialLinks!.whatsappLink != null && dashboardState.socialLinks!.whatsappLink!.isNotEmpty)
                    _buildSocialIcon(
                      icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), size: 24),
                      color: const Color(0xFF25D366),
                      onTap: () {
                        String waLink = dashboardState.socialLinks!.whatsappLink!;
                        if (!waLink.startsWith('http')) {
                          if (waLink.length == 10 && !waLink.startsWith('+')) waLink = '91$waLink';
                          waLink = 'https://wa.me/$waLink';
                        }
                        _launchURL(waLink);
                      },
                    ),
                  if (dashboardState.socialLinks!.instagramLink != null && dashboardState.socialLinks!.instagramLink!.isNotEmpty)
                    _buildSocialIcon(
                      icon: const FaIcon(FontAwesomeIcons.instagram, color: Color(0xFFE4405F), size: 24),
                      color: const Color(0xFFE4405F),
                      onTap: () => _launchURL(dashboardState.socialLinks!.instagramLink!),
                    ),
                  if (dashboardState.socialLinks!.linkedinLink != null && dashboardState.socialLinks!.linkedinLink!.isNotEmpty)
                    _buildSocialIcon(
                      icon: const FaIcon(FontAwesomeIcons.linkedin, color: Color(0xFF0A66C2), size: 24),
                      color: const Color(0xFF0A66C2),
                      onTap: () => _launchURL(dashboardState.socialLinks!.linkedinLink!),
                    ),
                  if (dashboardState.socialLinks!.twitterLink != null && dashboardState.socialLinks!.twitterLink!.isNotEmpty)
                    _buildSocialIcon(
                      icon: const FaIcon(FontAwesomeIcons.xTwitter, color: Colors.black, size: 24),
                      color: Colors.black,
                      onTap: () => _launchURL(dashboardState.socialLinks!.twitterLink!),
                    ),
                  if (dashboardState.socialLinks!.emailLink != null && dashboardState.socialLinks!.emailLink!.isNotEmpty)
                    _buildSocialIcon(
                      icon: const Icon(Icons.email, color: Color(0xFFD44638), size: 24),
                      color: const Color(0xFFD44638),
                      onTap: () => _launchURL('mailto:${dashboardState.socialLinks!.emailLink!}'),
                    ),
                  if (dashboardState.socialLinks!.youtubeLink != null && dashboardState.socialLinks!.youtubeLink!.isNotEmpty)
                    _buildSocialIcon(
                      icon: const FaIcon(FontAwesomeIcons.youtube, color: Color(0xFFFF0000), size: 24),
                      color: const Color(0xFFFF0000),
                      onTap: () => _launchURL(dashboardState.socialLinks!.youtubeLink!),
                    ),
                ],
              ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSlide(BannerModel banner) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          banner.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: MMPApp.maroon,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int tabIndex) {
    final dashboardState = context.findAncestorStateOfType<DashboardScreenState>();
    if (dashboardState != null) {
      dashboardState.navigateToTab(tabIndex);
    }
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    String title,
    String date,
    String location,
    bool isFeatured, {
    String? imageUrl,
  }) {
    return InkWell(
      onTap: () => _navigateToTab(context, 1),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isFeatured ? Border.all(color: MMPApp.orange, width: 2) : null,
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isFeatured
                    ? MMPApp.orange.withValues(alpha: 0.15)
                    : MMPApp.maroon.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                image: imageUrl != null && imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null || imageUrl.isEmpty
                  ? Icon(
                      Icons.event,
                      color: isFeatured ? MMPApp.orange : MMPApp.maroon,
                      size: 28,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFeatured)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: MMPApp.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(
    BuildContext context,
    String title,
    String excerpt,
    String time, {
    String? imageUrl,
  }) {
    return InkWell(
      onTap: () => _navigateToTab(context, 2),
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                image: imageUrl != null && imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null || imageUrl.isEmpty
                  ? const Icon(
                      Icons.article,
                      color: Colors.blue,
                      size: 28,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    excerpt,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MMPApp.orange.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: MMPApp.orange, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon({required Widget icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: icon,
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }
}

// Ad Slide data model
class AdSlide {
  final String title;
  final String subtitle;
  final String description;
  final List<Color> gradient;
  final IconData icon;

  AdSlide({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradient,
    required this.icon,
  });
}
