import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mmp_official/screens/auth/login/ui/login_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmp_official/main.dart';
import 'package:mmp_official/screens/profile/notifier/profile_notifier.dart';
import 'package:mmp_official/screens/profile/ui/profile_edit_screen.dart';
import 'package:mmp_official/screens/auth/login/riverpod/login_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
        ref.read(profileNotifierProvider.notifier).loadProfile();

    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileNotifierProvider);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: MMPApp.cream,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  // Banner & Avatar Stack
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25 + 50,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // Background Image
                        Container(
                          height: MediaQuery.of(context).size.height * 0.25,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: profile?.backgroundImage == null
                                ? const LinearGradient(
                                    colors: [MMPApp.maroon, MMPApp.maroonLight],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            image: profile?.backgroundImage != null
                                ? DecorationImage(
                                    image: NetworkImage(profile!.backgroundImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                        // Avatar
                        Positioned(
                          bottom: 0,
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: MMPApp.maroon.withValues(alpha: 0.3), width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  backgroundImage: profile?.image != null ? NetworkImage(profile!.image!) : null,
                                  child: profile?.image == null
                                      ? Text(
                                          profile?.name != null && profile!.name.isNotEmpty
                                              ? profile.name.substring(0, 1).toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: MMPApp.maroon,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: MMPApp.orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.verified,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile?.name ?? 'Loading...',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (profile?.mobile != null)
                    Text(
                      profile!.mobile,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Member Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: MMPApp.maroon.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: MMPApp.maroon.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: MMPApp.gold,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          profile?.villageName ?? 'Member',
                          style: const TextStyle(
                            color: MMPApp.maroon,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Stats
            // Container(
            //   margin: const EdgeInsets.all(16),
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(16),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black.withValues(alpha: 0.05),
            //         blurRadius: 10,
            //         offset: const Offset(0, 2),
            //       ),
            //     ],
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: [
            //       _buildStatItem('12', 'Events\nAttended', MMPApp.maroon),
            //       Container(height: 40, width: 1, color: Colors.grey[200]),
            //       _buildStatItem('3', 'Years\nActive', MMPApp.orange),
            //       Container(height: 40, width: 1, color: Colors.grey[200]),
            //       _buildStatItem('Delhi', 'Chapter', Colors.green),
            //     ],
            //   ),
            // ),
            // Profile Details
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MMPApp.maroon,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: MMPApp.maroon)),
                    )
                  else if (profile != null)
                    _buildInfoCard([
                      if (profile.labelName?.isNotEmpty == true) _buildInfoRow(Icons.label, 'Label Name', profile.labelName!),
                      if (profile.fatherName?.isNotEmpty == true) _buildInfoRow(Icons.person_outline, 'Father Name', profile.fatherName!),
                      if (profile.email?.isNotEmpty == true) _buildInfoRow(Icons.email, 'Email', profile.email!),
                      if (profile.mobile.isNotEmpty) _buildInfoRow(Icons.phone, 'Phone', profile.mobile),
                      if (profile.gender?.isNotEmpty == true) _buildInfoRow(Icons.wc, 'Gender', profile.gender!),
                      if (profile.age?.isNotEmpty == true) _buildInfoRow(Icons.cake, 'Age', profile.age!),
                      if (profile.dateOfBirth != null) _buildInfoRow(Icons.cake, 'Date of Birth', profile.dateOfBirth!.toString().split(' ')[0]),
                      if (profile.anniversaryDate != null) _buildInfoRow(Icons.celebration, 'Anniversary Date', profile.anniversaryDate!.toString().split(' ')[0]),
                      if (profile.bloodGroup?.isNotEmpty == true) _buildInfoRow(Icons.bloodtype, 'Blood Group', profile.bloodGroup!),
                      if (profile.occupation?.isNotEmpty == true) _buildInfoRow(Icons.work, 'Occupation', profile.occupation!),
                      if (profile.education?.isNotEmpty == true) _buildInfoRow(Icons.school, 'Education', profile.education!),
                      if (profile.villageName?.isNotEmpty == true) _buildInfoRow(Icons.home, 'Village', profile.villageName!),
                      if (profile.gotra?.isNotEmpty == true) _buildInfoRow(Icons.family_restroom, 'Gotra', profile.gotra!),
                    ]),

                  if (profile != null &&
                     (profile.msFirmName?.isNotEmpty == true || 
                      profile.businessType?.isNotEmpty == true ||
                      profile.productService?.isNotEmpty == true ||
                      profile.officeAddress?.isNotEmpty == true)) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Business Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MMPApp.maroon,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard([
                      if (profile.msFirmName?.isNotEmpty == true) _buildInfoRow(Icons.business, 'Firm Name', profile.msFirmName!),
                      if (profile.businessType?.isNotEmpty == true) _buildInfoRow(Icons.store, 'Business Type', profile.businessType!),
                      if (profile.productService?.isNotEmpty == true) _buildInfoRow(Icons.category, 'Product / Service', profile.productService!),
                      if (profile.officeAddress?.isNotEmpty == true) _buildInfoRow(Icons.business_center, 'Office Address', profile.officeAddress!),
                    ]),
                  ],

                  if (profile != null &&
                     (profile.address2?.isNotEmpty == true || 
                      profile.city?.isNotEmpty == true ||
                      profile.pincode?.isNotEmpty == true)) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Address Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MMPApp.maroon,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard([
                      if (profile.address2?.isNotEmpty == true) _buildInfoRow(Icons.home, 'Address (Home)', profile.address2!),
                      if (profile.city?.isNotEmpty == true) _buildInfoRow(Icons.location_city, 'City', profile.city!),
                      if (profile.pincode?.isNotEmpty == true) _buildInfoRow(Icons.pin_drop, 'Pincode', profile.pincode!),
                    ]),
                  ],
                ],
              ),
            ),
            // const SizedBox(height: 16),
            // // Settings
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Text(
            //         'Settings',
            //         style: TextStyle(
            //           fontSize: 18,
            //           fontWeight: FontWeight.bold,
            //           color: MMPApp.maroon,
            //         ),
            //       ),
            //       const SizedBox(height: 12),
            //       _buildSettingsCard(context),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 16),
            // // Support
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Text(
            //         'Support',
            //         style: TextStyle(
            //           fontSize: 18,
            //           fontWeight: FontWeight.bold,
            //           color: MMPApp.maroon,
            //         ),
            //       ),
            //       const SizedBox(height: 12),
            //       _buildSupportCard(context),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 24),
            // Delete Account Button (iOS Only)
            if (Platform.isIOS) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: state.isDeleting ? null : () {
                      _showDeleteAccountDialog(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.isDeleting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_forever),
                              SizedBox(width: 8),
                              Text(
                                'Delete Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // App Version
            Text(
              'MMP App v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MMPApp.maroon.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: MMPApp.maroon, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
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
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          _buildSettingsTile(
            Icons.notifications_outlined,
            'Notifications',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeTrackColor: MMPApp.maroon.withValues(alpha: 0.5),
              activeThumbColor: MMPApp.maroon,
            ),
          ),
          _buildDivider(),
          _buildSettingsTile(
            Icons.language,
            'Language',
            subtitle: 'English',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingsTile(
            Icons.dark_mode_outlined,
            'Dark Mode',
            trailing: Switch(
              value: false,
              onChanged: (value) {},
              activeTrackColor: MMPApp.maroon.withValues(alpha: 0.5),
              activeThumbColor: MMPApp.maroon,
            ),
          ),
          _buildDivider(),
          _buildSettingsTile(
            Icons.lock_outlined,
            'Privacy',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          _buildSettingsTile(
            Icons.help_outline,
            'Help Center',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingsTile(
            Icons.feedback_outlined,
            'Send Feedback',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingsTile(
            Icons.info_outline,
            'About Mel Milaap Parivaar',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingsTile(
            Icons.description_outlined,
            'Terms & Conditions',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title, {
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: MMPApp.maroon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[200]);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(loginProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to permanently delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(profileNotifierProvider.notifier).deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
