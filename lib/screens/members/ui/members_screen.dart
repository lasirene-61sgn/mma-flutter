import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmp_official/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mmp_official/service/toaster.dart';
import '../model/member_model.dart';
import '../riverpod/member_notifier.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(membersNotifierProvider.notifier).loadMembers('api/customer/customers');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MMPApp.cream,
      body: Column(
        children: [
          // Title Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [MMPApp.maroon, MMPApp.maroonLight],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.groups, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Members',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Our MMP family members',
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
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: 'Search members...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey[400]),
                  // suffixIcon: IconButton(
                  //   icon: Icon(Icons.filter_list, color: Colors.grey[400]),
                  //   onPressed: () => _showFilterSheet(),
                  // ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Members List
          Expanded(
            child: _buildMembersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    final state = ref.watch(membersNotifierProvider);

    if (state.isLoading && state.filteredList.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: MMPApp.maroon));
    }

    final allMembers = state.filteredList;

    // Filter members based on search query
    final members = _searchQuery.isEmpty
        ? allMembers
        : allMembers.where((m) =>
            m.name.toLowerCase().contains(_searchQuery) ||
            (m.nativePlace?.toLowerCase().contains(_searchQuery) ?? false) ||
            (m.occupation?.toLowerCase().contains(_searchQuery) ?? false) ||
            (m.officeAddress?.toLowerCase().contains(_searchQuery) ?? false)).toList();

    if (members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              state.isLoading ? 'Searching...' : 'No members found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.isLoading ? 'Please wait' : 'Try a different search term',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: members.length + 1,
      itemBuilder: (context, index) {
        if (index == members.length) {
          return const SizedBox(height: 80);
        }
        return _buildMemberCard(members[index]);
      },
    );
  }

  Widget _buildMemberCard(Member member) {
    return InkWell(
      onTap: () => _showMemberDetailsDialog(member),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'member_${member.name}',
              child: CircleAvatar(
                radius: 28,
                backgroundColor: MMPApp.maroon.withValues(alpha: 0.1),
                backgroundImage: member.image != null && member.image!.isNotEmpty
                    ? NetworkImage(member.image!)
                    : null,
                child: member.image == null || member.image!.isEmpty
                    ? Text(
                        member.name.isNotEmpty ? member.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().substring(0, member.name.split(' ').length > 1 ? 2 : 1) : '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MMPApp.maroon,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          member.nativePlace ?? 'N/A',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.work, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          member.occupation ?? 'N/A',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   children: [
            //     Container(
            //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            //       decoration: BoxDecoration(
            //         color: MMPApp.maroon.withValues(alpha: 0.1),
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //       child: Text(
            //         'Since ${member.createdAt.year}',
            //         style: const TextStyle(
            //           fontSize: 11,
            //           color: MMPApp.maroon,
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //     ),
            //     const SizedBox(height: 8),
            //     Icon(
            //       Icons.arrow_forward_ios,
            //       color: Colors.grey[400],
            //       size: 16,
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  void _showMemberDetailsDialog(Member member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
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
                if (member.backgroundImage != null && member.backgroundImage!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // Background Image
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(member.backgroundImage!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Avatar and Details
                        Padding(
                          padding: const EdgeInsets.only(top: 155), // Overlaps the background
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: MMPApp.maroon.withValues(alpha: 0.3), width: 2),
                                ),
                                child: Hero(
                                  tag: 'member_${member.name}',
                                  child: CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.white,
                                    backgroundImage: member.image != null && member.image!.isNotEmpty
                                        ? NetworkImage(member.image!)
                                        : null,
                                    child: member.image == null || member.image!.isEmpty
                                        ? Text(
                                            member.name.isNotEmpty ? member.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().substring(0, member.name.split(' ').length > 1 ? 2 : 1) : '',
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: MMPApp.maroon,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                member.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildHeaderChip(Icons.work, (member.occupation ?? 'N/A').split(',').first),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          MMPApp.maroon.withValues(alpha: 0.08),
                          Colors.white,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        Hero(
                          tag: 'member_${member.name}',
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: MMPApp.maroon.withValues(alpha: 0.15),
                            backgroundImage: member.image != null && member.image!.isNotEmpty
                                ? NetworkImage(member.image!)
                                : null,
                            child: member.image == null || member.image!.isEmpty
                                ? Text(
                                    member.name.isNotEmpty ? member.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().substring(0, member.name.split(' ').length > 1 ? 2 : 1) : '',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: MMPApp.maroon,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildHeaderChip(Icons.work, (member.occupation ?? 'N/A').split(',').first),
                          ],
                        ),
                      ],
                    ),
                  ),
                // Scrollable Details
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Personal Information
                      _buildSectionCard(
                        'Personal Information',
                        Icons.person,
                        [
                          _buildDetailRow(Icons.person, 'Full Name', member.name),
                          _buildDetailRow(Icons.family_restroom, "Father's Name", member.fatherName ?? 'N/A'),
                          _buildDetailRow(Icons.home, 'Native Place', member.nativePlace ?? 'N/A'),
                          _buildDetailRow(Icons.cake, 'Date of Birth', _formatDate(member.dateOfBirth)),
                          _buildDetailRow(Icons.school, 'Education', member.education ?? 'N/A'),
                          _buildDetailRow(Icons.work, 'Occupation', member.occupation ?? 'N/A'),
                          _buildDetailRow(Icons.bloodtype, 'Blood Group', member.bloodGroup ?? 'N/A'),
                          _buildDetailRow(Icons.interests, 'Hobbies', member.hobbies ?? 'N/A'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Spouse Information
                      Builder(
                        builder: (context) {
                          final spouseList = member.familyMembers.where((f) => f.relationship?.toLowerCase() == 'spouse' || f.relationship?.toLowerCase() == 'wife' || f.relationship?.toLowerCase() == 'husband').toList();
                          final spouse = spouseList.isNotEmpty ? spouseList.first : null;
                          
                          if (spouse == null) return const SizedBox.shrink();
                          
                          return Column(
                            children: [
                              _buildSectionCard(
                                'Spouse Information',
                                Icons.favorite,
                                [
                                  _buildDetailRow(Icons.person, 'Spouse Name', spouse.name),
                                  _buildDetailRow(Icons.cake, 'Date of Birth', _formatDate(spouse.dateOfBirth)),
                                  _buildDetailRow(Icons.school, 'Education', spouse.education ?? 'N/A'),
                                  _buildDetailRow(Icons.work, 'Occupation', spouse.occupation ?? 'N/A'),
                                  _buildDetailRow(Icons.bloodtype, 'Blood Group', spouse.bloodGroup ?? 'N/A'),
                                  _buildDetailRow(Icons.interests, 'Hobbies', spouse.hobbies ?? 'N/A'),
                                  _buildDetailRow(Icons.celebration, 'Wedding Date', _formatDate(spouse.anniversaryDate)),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }
                      ),
                      
                      // Contact Details
                      Builder(
                        builder: (context) {
                          final spouseList = member.familyMembers.where((f) => f.relationship?.toLowerCase() == 'spouse' || f.relationship?.toLowerCase() == 'wife' || f.relationship?.toLowerCase() == 'husband').toList();
                          final spouse = spouseList.isNotEmpty ? spouseList.first : null;
                          return _buildSectionCard(
                            'Contact Details',
                            Icons.contact_phone,
                            [
                              _buildDetailRow(Icons.phone_android, 'Mobile (Self)', member.mobile),
                              if (spouse?.mobile != null && spouse!.mobile!.isNotEmpty)
                                _buildDetailRow(Icons.phone_android, 'Mobile (Spouse)', spouse.mobile!),
                              _buildDetailRow(Icons.email, 'Email', member.email ?? 'N/A'),
                            ],
                          );
                        }
                      ),
                      const SizedBox(height: 16),
                      
                      // Address Details
                      _buildSectionCard(
                        'Address Details',
                        Icons.location_on,
                        [
                          _buildDetailRow(Icons.business, 'Office Address', member.officeAddress ?? 'N/A'),
                          _buildDetailRow(Icons.home, 'Residential Address', '${member.streetRoad ?? ''} ${member.city ?? ''} ${member.pincode ?? ''}'.trim().isEmpty ? 'N/A' : '${member.streetRoad ?? ''} ${member.city ?? ''} ${member.pincode ?? ''}'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Children Details
                      Builder(
                        builder: (context) {
                          final childrenList = member.familyMembers.where((f) => ['son', 'daughter', 'child'].contains(f.relationship?.toLowerCase())).toList();
                          if (childrenList.isEmpty) return const SizedBox.shrink();
                          return _buildChildrenSection(childrenList);
                        }
                      ),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(16),
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
                            if (member.mobile.isNotEmpty) {
                              final Uri url = Uri.parse('tel:${member.mobile}');
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      // const SizedBox(width: 12),
                      // Expanded(
                      //   child: ElevatedButton.icon(
                      //     onPressed: () {
                      //       Navigator.pop(context);
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(
                      //           content: Text('Opening email to ${member.email}...'),
                      //           backgroundColor: MMPApp.maroon,
                      //           behavior: SnackBarBehavior.floating,
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(10),
                      //           ),
                      //         ),
                      //       );
                      //     },
                      //     icon: const Icon(Icons.email, color: Colors.white),
                      //     label: const Text('Email'),
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: MMPApp.maroon,
                      //       foregroundColor: Colors.white,
                      //       padding: const EdgeInsets.symmetric(vertical: 12),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: MMPApp.maroon.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: MMPApp.maroon, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: MMPApp.maroon,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
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

  Widget _buildChildrenSection(List<FamilyMember> children) {
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
                  color: MMPApp.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.child_care, color: MMPApp.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Children (${children.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: MMPApp.maroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;
            final isMale = child.gender?.toLowerCase() == 'male';
            return Container(
              margin: EdgeInsets.only(bottom: index < children.length - 1 ? 12 : 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MMPApp.borderBrown.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isMale 
                        ? Colors.blue.withValues(alpha: 0.15)
                        : Colors.pink.withValues(alpha: 0.15),
                    child: Icon(
                      isMale ? Icons.boy : Icons.girl,
                      color: isMale ? Colors.blue : Colors.pink,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              child.gender ?? 'N/A',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(' • ', style: TextStyle(color: Colors.grey[400])),
                            Text(
                              _formatDate(child.dateOfBirth),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (child.dateOfBirth != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: MMPApp.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_calculateAge(child.dateOfBirth!)} yrs',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MMPApp.orange,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[500], size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Members',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MMPApp.maroon,
              ),
            ),
            const SizedBox(height: 20),
            const Text('By City', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(label: const Text('All'), selected: true, onSelected: (_) {}),
                FilterChip(label: const Text('Mumbai'), selected: false, onSelected: (_) {}),
                FilterChip(label: const Text('Delhi'), selected: false, onSelected: (_) {}),
                FilterChip(label: const Text('Bangalore'), selected: false, onSelected: (_) {}),
                FilterChip(label: const Text('Hyderabad'), selected: false, onSelected: (_) {}),
                FilterChip(label: const Text('Pune'), selected: false, onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 20),
            const Text('By Blood Group', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(label: const Text('All'), selected: true, onSelected: (_) {}),
                FilterChip(label: const Text('A+'), selected: false, onSelected: (_) {}),
                FilterChip(label: const Text('B+'), selected: false, onSelected: (_) {}),
                FilterChip(label: const Text('O+'), selected: false, onSelected: (_) {}),
                FilterChip(label: const Text('AB+'), selected: false, onSelected: (_) {}),
                FilterChip(label: const Text('A-'), selected: false, onSelected: (_) {}),
                FilterChip(label: const Text('B-'), selected: false, onSelected: (_) {}),
                FilterChip(label: const Text('O-'), selected: false, onSelected: (_) {}),
                FilterChip(label: const Text('AB-'), selected: false, onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

