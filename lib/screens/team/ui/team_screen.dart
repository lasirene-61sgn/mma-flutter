import 'package:flutter/material.dart';
import '../../../main.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mmp_official/service/toaster.dart';
import '../notifier/team_notifier.dart';

class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {

        ref.read(teamNotifierProvider.notifier).loadTeam();

    });
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamNotifierProvider);

    return Scaffold(
      backgroundColor: MMPApp.cream,
      body: state.isLoading && state.teamList.isEmpty
          ? const Center(child: CircularProgressIndicator(color: MMPApp.maroon))
          : state.teamList.isEmpty && !state.isLoading
              ? const Center(child: Text('No team members found', style: TextStyle(color: Colors.grey)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Title Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [MMPApp.maroon, MMPApp.maroonLight],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.stars, color: MMPApp.gold, size: 32),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Our Team',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Meet the dedicated team members of MMP',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dynamic Members
                    ...state.teamList.map((member) {
                      final isPresident = member.postName.toLowerCase().contains('president');
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildLeaderCard(
                          name: member.name,
                          position: member.postName,
                          description: 'Member of MMP Team',
                          phone: member.phone,
                          email: '',
                          isPresident: isPresident,
                          imagePath: member.imagePath,
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 80),
                  ],
                ),
    );
  }

  Widget _buildLeaderCard({
    required String name,
    required String position,
    required String description,
    required String email,
    required String phone,
    bool isPresident = false,
    String? imagePath,
  }) {
    return InkWell(
      onTap: () => _showMemberDetailsDialog(
        name: name,
        position: position,
        phone: phone,
        description: description,
        isLeader: true,
        imagePath: imagePath,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isPresident
              ? const LinearGradient(colors: [MMPApp.maroon, MMPApp.maroonLight])
              : null,
          color: isPresident ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: MMPApp.maroon.withValues(alpha: isPresident ? 0.3 : 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'leader_$name',
              child: CircleAvatar(
                radius: 35,
                backgroundColor: isPresident ? Colors.white : MMPApp.maroon.withValues(alpha: 0.1),
                backgroundImage: imagePath != null ? NetworkImage(imagePath) : null,
                child: imagePath == null ? Text(
                  name.isNotEmpty ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join() : '?',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: MMPApp.maroon,
                  ),
                ) : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isPresident ? Colors.white : const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPresident ? MMPApp.orange : MMPApp.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      position,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPresident ? Colors.white : MMPApp.orange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isPresident ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (isPresident)
                  const Icon(Icons.verified, color: MMPApp.gold, size: 28),
                const SizedBox(height: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isPresident ? Colors.white54 : Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  void _showMemberDetailsDialog({
    required String name,
    required String phone,
    String? position,
    String? city,
    String? description,
    bool isLeader = false,
    String? imagePath,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
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
            // Header with Profile
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MMPApp.maroon.withValues(alpha: 0.05),
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'leader_$name',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: MMPApp.maroon.withValues(alpha: 0.15),
                      backgroundImage: imagePath != null ? NetworkImage(imagePath) : null,
                      child: imagePath == null ? Text(
                        name.isNotEmpty ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join() : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: MMPApp.maroon,
                        ),
                      ) : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  if (position != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [MMPApp.maroon, MMPApp.maroonLight],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            position,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            // Details
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildDetailCard(
                    'Contact Information',
                    Icons.contact_phone,
                    [
                      _buildDetailRow(Icons.phone, 'Phone', phone),
                      if (city != null) _buildDetailRow(Icons.location_on, 'Location', city),
                    ],
                  ),
                ],
              ),
            ),
            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (phone.isNotEmpty) {
                          final Uri url = Uri.parse('tel:$phone');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            if (context.mounted) {
                              Toaster.showError('Could not launch phone dialer');
                            }
                          }
                        } else {
                          if (context.mounted) {
                            Toaster.showError('No phone number available');
                          }
                        }
                      },
                      icon: const Icon(Icons.phone, color: MMPApp.maroon),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MMPApp.maroon,
                        side: const BorderSide(color: MMPApp.maroon),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  Widget _buildDetailCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MMPApp.borderBrown.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MMPApp.maroon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: MMPApp.maroon, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: MMPApp.maroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[500], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
