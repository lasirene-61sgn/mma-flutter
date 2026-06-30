import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmp_official/screens/dashboard/notifier/dashboard_notifier.dart';
import 'widgets/notification_bottom_sheet.dart';
import '../../../main.dart';
import '../../events/ui/events_screen.dart';
import '../../gallery/ui/gallery_screen.dart';
import '../../home/ui/home_screen.dart';
import '../../mmpct/ui/mmpct_screen.dart';
import '../../team/ui/team_screen.dart';
import '../../members/ui/members_screen.dart';
import '../../news/ui/news_screen.dart';
import '../../profile/ui/profile_screen.dart';
import '../../profile/ui/family_details_screen.dart';
import '../../auth/login/riverpod/login_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  void navigateToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    EventsScreen(),
    NewsScreen(),
    TeamScreen(),
    MembersScreen(),
  ];

  final List<String> _titles = const [
    'Home',
    'Events',
    'News',
    'Team',
    'Members',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/images/mmp_logo.jpeg',
                width: 28,
                height: 28,
              ),
            ),
            const SizedBox(width: 10),
            Text(_titles[_selectedIndex]),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              NotificationBottomSheet.show(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          backgroundColor: Colors.white,
          indicatorColor: MMPApp.maroon.withValues(alpha: 0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: MMPApp.maroon),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event, color: MMPApp.maroon),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.newspaper_outlined),
              selectedIcon: Icon(Icons.newspaper, color: MMPApp.maroon),
              label: 'News',
            ),
            NavigationDestination(
              icon: Icon(Icons.stars_outlined),
              selectedIcon: Icon(Icons.stars, color: MMPApp.maroon),
              label: 'Team',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups, color: MMPApp.maroon),
              label: 'Members',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    final dashboardState = ref.watch(dashboardNotifierProvider);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [MMPApp.maroon, MMPApp.maroonLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/mmp_logo.jpeg',
                    width: 60,
                    height: 60,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mel Milaap Parivaar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'TOGETHER • TOWARDS • TOMORROW',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.home, 'Home', 0),
          _buildDrawerItem(Icons.event, 'Events', 1, badgeCount: dashboardState.dashboardCounters?.newEventCount ?? 0),
          _buildDrawerItem(Icons.newspaper, 'News', 2, badgeCount: dashboardState.dashboardCounters?.newNewsCount ?? 0),
          _buildDrawerItem(Icons.stars, 'Team', 3, badgeCount: dashboardState.dashboardCounters?.newCommitteeCount ?? 0),
          _buildDrawerItem(Icons.groups, 'Members', 4, badgeCount: dashboardState.dashboardCounters?.newCustomerCount ?? 0),
          const Divider(),
          // MMPCT Module
          // ListTile(
          //   leading: Container(
          //     padding: const EdgeInsets.all(6),
          //     decoration: BoxDecoration(
          //       color: MMPApp.orange.withValues(alpha: 0.1),
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: const Icon(Icons.account_balance, color: MMPApp.orange, size: 20),
          //   ),
          //   title: const Text('MMPCT', style: TextStyle(fontWeight: FontWeight.w600)),
          //   subtitle: const Text('Charitable Trust', style: TextStyle(fontSize: 11)),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => const MMPCTScreen()),
          //     );
          //   },
          // ),
          // const Divider(),
          ListTile(
            leading: const Icon(Icons.family_restroom, color: MMPApp.maroon),
            title: const Text('Family Details'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FamilyDetailsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: MMPApp.maroon),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GalleryScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: MMPApp.maroon),
            title: const Text('About Mel Milaap Parivaar'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail_outlined, color: MMPApp.maroon),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              _showContactDialog();
            },
          ),
          if (dashboardState.donate?.imageUrl != null && dashboardState.donate!.imageUrl.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.volunteer_activism, color: MMPApp.orange),
              title: const Text('Donate'),
              onTap: () {
                Navigator.pop(context);
                _showDonateDialog();
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Colors.grey),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index, {int badgeCount = 0}) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? MMPApp.maroon : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? MMPApp.maroon : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: badgeCount > 0
          ? Container(
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
            )
          : null,
      selected: isSelected,
      selectedTileColor: MMPApp.maroon.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }



  void showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Image.asset('assets/images/mmp_logo.jpeg', width: 40, height: 40),
            const SizedBox(width: 12),
            const Expanded(child: Text('About Mel Milaap Parivaar')),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mel Milaap Parivaar (MMP) is dedicated to empowering our community through unity, leadership development, and cultural preservation.',
            ),
            SizedBox(height: 16),
            Text('Founded: 2010'),
            Text('Chapter: 1'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Contact Us'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContactRow(Icons.email, 'contact@iya.org'),
            _buildContactRow(Icons.phone, '+91 9363705055'),
            _buildContactRow(Icons.location_on, 'New Delhi, India'),
            _buildContactRow(Icons.language, 'www.iya.org'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: MMPApp.maroon, size: 20),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  void _showDonateDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final donate = ref.watch(dashboardNotifierProvider).donate;
          
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: EdgeInsets.zero,
            content: Stack(
              clipBehavior: Clip.none,
              children: [
                donate?.imageUrl != null && donate!.imageUrl.isNotEmpty
                    ? Container(
                        constraints: const BoxConstraints(
                          maxHeight: 400,
                          maxWidth: 400,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            donate.imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) => const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('Error loading QR Code.'),
                            ),
                          ),
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text('No QR Code available right now.'),
                      ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout from your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Logout using login provider
              ref.read(loginProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
