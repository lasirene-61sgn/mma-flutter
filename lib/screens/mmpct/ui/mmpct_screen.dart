import 'package:flutter/material.dart';
import '../../../main.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mmp_official/service/toaster.dart';
import '../notifier/mmpct_notifier.dart';

class MMPCTScreen extends ConsumerStatefulWidget {
  const MMPCTScreen({super.key});

  @override
  ConsumerState<MMPCTScreen> createState() => _MMPCTScreenState();
}

class _MMPCTScreenState extends ConsumerState<MMPCTScreen> {
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(mmpctNotifierProvider.notifier).loadMembers('api/customer/support');
      ref.read(mmpctNotifierProvider.notifier).loadCategory('api/customer/support/categories');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mmpctNotifierProvider);
    return Scaffold(
      backgroundColor: MMPApp.cream,
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
            const Text('MMPCT'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (state.categoryList.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: const BoxDecoration(
                color: MMPApp.maroon,

              ),
              child: Column(
                children: [
                  SizedBox(
                    height: state.categoryList.isEmpty ? 30 : 40,
                    child: state.categoryList.isEmpty
                        ? const SizedBox()
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.categoryList.length,
                      itemBuilder: (context, index) {
                        final category = state.categoryList[index];
                        final isSelected = category.categoryName == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () async {
                              if (_selectedCategory == category.categoryName) return;

                              setState(() {
                                _selectedCategory = category.categoryName;
                              });

                              final String url = (category.categoryName == "All")
                                  ? "api/customer/support"
                                  : "api/customer/support/categories?category=${category.categoryName}";

                              await ref.read(mmpctNotifierProvider.notifier).loadMembers(url);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category.categoryName,
                                style: TextStyle(
                                  color: isSelected ? MMPApp.maroon : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          // MMPCT Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MMPApp.maroon.withValues(alpha: 0.1),
                  MMPApp.orange.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: MMPApp.maroon,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Mel Milaap Parivaar Charitable Trust',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Serving the Community Since 2010',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: state.isLoading 
                ? const Center(child: CircularProgressIndicator(color: MMPApp.maroon))
                : Builder(
                    builder: (context) {
                      final catMembers = state.memberList.map((m) => TrusteeModel(
                        name: m.name,
                        position: _selectedCategory,
                        designation: _selectedCategory,
                        phone: m.phone,
                        email: 'N/A',
                        since: 'N/A',
                        address: 'N/A',
                        occupation: 'N/A',
                        photo: m.image
                      )).toList();

                      return _buildTrusteeList(catMembers, _selectedCategory, Icons.people, Colors.blue);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrusteeList(List<TrusteeModel> trustees, String title, IconData icon, Color color) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trustees.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        '${trustees.length} Members',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        
        final trustee = trustees[index - 1];
        return _buildTrusteeCard(trustee, color);
      },
    );
  }

  Widget _buildTrusteeCard(TrusteeModel trustee, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTrusteeDetails(trustee, accentColor),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: trustee.photo != null && trustee.photo!.isNotEmpty 
                      ? () => _showFullImage(trustee.photo!) 
                      : null,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      image: trustee.photo != null && trustee.photo!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(trustee.photo!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: trustee.photo == null || trustee.photo!.isEmpty
                        ? Center(
                            child: Text(
                              _getInitials(trustee.name),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trustee.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trustee.position,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              trustee.address,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.replaceAll('Shri ', '').split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return parts[0][0];
  }

  void _showTrusteeDetails(TrusteeModel trustee, Color accentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        image: trustee.photo != null && trustee.photo!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(trustee.photo!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: trustee.photo == null || trustee.photo!.isEmpty
                          ? Center(
                              child: Text(
                                _getInitials(trustee.name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      trustee.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        trustee.position,
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trustee.designation,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Info Cards
                    _buildInfoCard(Icons.work, 'Occupation', trustee.occupation, accentColor),
                    _buildInfoCard(Icons.location_on, 'Address', trustee.address, accentColor),
                    _buildInfoCard(Icons.calendar_today, 'Member Since', trustee.since, accentColor),
                    _buildInfoCard(Icons.phone, 'Phone', trustee.phone, accentColor),
                    _buildInfoCard(Icons.email, 'Email', trustee.email, accentColor),
                    const SizedBox(height: 24),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              if (trustee.phone.isNotEmpty) {
                                final Uri url = Uri.parse('tel:${trustee.phone}');
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
                            icon: const Icon(Icons.call),
                            label: const Text('Call'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: accentColor),
                              foregroundColor: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
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

class TrusteeModel {
  final String name;
  final String position;
  final String designation;
  final String phone;
  final String email;
  final String? photo;
  final String since;
  final String address;
  final String occupation;

  TrusteeModel({
    required this.name,
    required this.position,
    required this.designation,
    required this.phone,
    required this.email,
    this.photo,
    required this.since,
    required this.address,
    required this.occupation,
  });
}
