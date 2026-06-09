import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mmp_official/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:mmp_official/screens/dashboard/model/dashboard_model.dart';
import 'package:mmp_official/screens/dashboard/notifier/dashboard_notifier.dart';

class AnniversaryScreen extends ConsumerStatefulWidget {
  const AnniversaryScreen({super.key});

  @override
  ConsumerState<AnniversaryScreen> createState() => _AnniversaryScreenState();
}

class _AnniversaryScreenState extends ConsumerState<AnniversaryScreen> {
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  late String _selectedMonth;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateFormat('MMMM').format(DateTime.now());
    
    int monthIndex = _months.indexOf(_selectedMonth);
    // Approximate width of each choice chip to calculate scroll offset
    double initialOffset = monthIndex > 2 ? (monthIndex - 1) * 90.0 : 0.0;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);

    Future.microtask(() {
      ref.read(dashboardNotifierProvider.notifier).loadAnniversaries();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isToday(DateTime dob) {
    final now = DateTime.now();
    return dob.day == now.day && dob.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardNotifierProvider);
    final dateMap = state.anniversaryData[_selectedMonth] ?? {};

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Anniversaries', style: TextStyle(color: Colors.black)),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(dashboardNotifierProvider.notifier).loadAnniversaries(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Month Selector
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _months.length,
                itemBuilder: (context, index) {
                  final month = _months[index];
                  final isSelected = month == _selectedMonth;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        month,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: MMPApp.maroon,
                      backgroundColor: Colors.grey.shade200,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedMonth = month;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            // Members List
            Expanded(
              child: state.isLoading && state.anniversaryData.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: MMPApp.maroon))
                  : dateMap.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.favorite_outline, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'No anniversaries in $_selectedMonth',
                                style: const TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: dateMap.entries.map((entry) {
                            final dateKey = entry.key;
                            final members = entry.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                  child: Text(
                                    dateKey,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                ...members.map((m) => _buildMemberTile(m)),
                                const SizedBox(height: 8),
                              ],
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberDetails(BuildContext context, BirthdayModel member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: MMPApp.maroon.withOpacity(0.1),
                        child: const Icon(Icons.person, color: MMPApp.maroon, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            if (member.anniversaryDate != null)
                              Text('Anniversary: ${DateFormat('dd MMMM yyyy').format(member.anniversaryDate!)}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (member.mobile.isNotEmpty || (member.email != null && member.email!.isNotEmpty))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (member.mobile.isNotEmpty)
                          _buildActionButton(const Icon(Icons.call, color: Colors.green), Colors.green, () => launchUrl(Uri.parse('tel:${member.mobile}'))),
                        if (member.mobile.isNotEmpty)
                          _buildActionButton(const Icon(Icons.message, color: Colors.blue), Colors.blue, () => launchUrl(Uri.parse('sms:${member.mobile}'))),
                        if (member.whatsapp != null && member.whatsapp!.isNotEmpty)
                          _buildActionButton(const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366)), const Color(0xFF25D366), () => launchUrl(Uri.parse('https://wa.me/${member.whatsapp}'))),
                        if (member.email != null && member.email!.isNotEmpty)
                          _buildActionButton(const Icon(Icons.email, color: Colors.red), Colors.red, () => launchUrl(Uri.parse('mailto:${member.email}'))),
                      ],
                    ),
                  const SizedBox(height: 24),
                  
                  // Details Info
                  if ((member.fatherName != null && member.fatherName!.isNotEmpty) ||
                      (member.gotra != null && member.gotra!.isNotEmpty) ||
                      (member.gender != null && member.gender!.isNotEmpty) ||
                      (member.age != null) ||
                      (member.bloodGroup != null && member.bloodGroup!.isNotEmpty) ||
                      (member.education != null && member.education!.isNotEmpty) ||
                      (member.hobbies != null && member.hobbies!.isNotEmpty) ||
                      (member.nativePlace != null && member.nativePlace!.isNotEmpty)) ...[
                    const Text("Personal Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (member.fatherName != null && member.fatherName!.isNotEmpty) _buildDetailRow("Father's Name", member.fatherName!),
                    if (member.gotra != null && member.gotra!.isNotEmpty) _buildDetailRow("Gotra", member.gotra!),
                    if (member.gender != null && member.gender!.isNotEmpty) _buildDetailRow("Gender", member.gender!),
                    if (member.age != null) _buildDetailRow("Age", member.age.toString()),
                    if (member.bloodGroup != null && member.bloodGroup!.isNotEmpty) _buildDetailRow("Blood Group", member.bloodGroup!),
                    if (member.education != null && member.education!.isNotEmpty) _buildDetailRow("Education", member.education!),
                    if (member.hobbies != null && member.hobbies!.isNotEmpty) _buildDetailRow("Hobbies", member.hobbies!),
                    if (member.nativePlace != null && member.nativePlace!.isNotEmpty) _buildDetailRow("Native Place", member.nativePlace!),
                    const Divider(height: 32),
                  ],

                  if ((member.occupation != null && member.occupation!.isNotEmpty) ||
                      (member.businessType != null && member.businessType!.isNotEmpty) ||
                      (member.businessName != null && member.businessName!.isNotEmpty) ||
                      (member.msFirmName != null && member.msFirmName!.isNotEmpty) ||
                      (member.productService != null && member.productService!.isNotEmpty) ||
                      (member.officeAddress != null && member.officeAddress!.isNotEmpty)) ...[
                    const Text("Professional Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (member.occupation != null && member.occupation!.isNotEmpty) _buildDetailRow("Occupation", member.occupation!),
                    if (member.businessType != null && member.businessType!.isNotEmpty) _buildDetailRow("Business Type", member.businessType!),
                    if (member.businessName != null && member.businessName!.isNotEmpty) _buildDetailRow("Business Name", member.businessName!),
                    if (member.msFirmName != null && member.msFirmName!.isNotEmpty) _buildDetailRow("Firm Name", member.msFirmName!),
                    if (member.productService != null && member.productService!.isNotEmpty) _buildDetailRow("Products/Services", member.productService!),
                    if (member.officeAddress != null && member.officeAddress!.isNotEmpty) _buildDetailRow("Office Address", member.officeAddress!),
                    const Divider(height: 32),
                  ],
                  
                  // Address Info
                  if ((member.village != null) || (member.area != null && member.area!.isNotEmpty) || (member.city != null && member.city!.isNotEmpty)) ...[
                    const Text("Address Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (member.village != null) _buildDetailRow("Village", member.village!.name),
                    if (member.area != null && member.area!.isNotEmpty) _buildDetailRow("Area", member.area!),
                    if (member.city != null && member.city!.isNotEmpty) _buildDetailRow("City", member.city!),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(Widget icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: icon,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          const Text(":  ", style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(BirthdayModel member) {
    final isToday = member.isToday || (member.anniversaryDate != null && _isToday(member.anniversaryDate!));

    return GestureDetector(
      onTap: () => _showMemberDetails(context, member),
      child: Opacity(
      opacity: isToday ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isToday ? MMPApp.maroon.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday ? MMPApp.maroon.withOpacity(0.5) : Colors.grey.shade300, 
            width: isToday ? 1.5 : 0.5
          ),
          boxShadow: [
            if (isToday)
              BoxShadow(
                color: MMPApp.maroon.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isToday ? MMPApp.maroon.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
              child: Icon(Icons.favorite, color: isToday ? MMPApp.maroon : Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      color: isToday ? Colors.black : Colors.grey.shade700,
                    )
                  ),
                  const SizedBox(height: 4),
                  if (member.anniversaryDate != null)
                    Text(DateFormat('dd MMM').format(member.anniversaryDate!), style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            if (isToday)
              const Chip(
                label: Text("TODAY", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                backgroundColor: Color(0xFFE8F5E9),
                padding: EdgeInsets.zero,
                side: BorderSide.none,
              ),
          ],
        ),
      ),
    ));
  }
}
