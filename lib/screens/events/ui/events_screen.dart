import 'package:flutter/material.dart';
import 'package:mmp_official/main.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifier/events_notifier.dart';
import '../model/event_model.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(eventsNotifierProvider.notifier).loadEvents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventsNotifierProvider);

    return Scaffold(
      backgroundColor: MMPApp.cream,
      body: Column(
        children: [
          // Featured Event Banner
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
          //         top: -20,
          //         child: Icon(
          //           Icons.celebration,
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
          //                 '🔥 FEATURED',
          //                 style: TextStyle(
          //                   fontSize: 10,
          //                   fontWeight: FontWeight.bold,
          //                   color: Colors.white,
          //                 ),
          //               ),
          //             ),
          //             const SizedBox(height: 12),
          //             const Text(
          //               'Annual Youth Conference 2025',
          //               style: TextStyle(
          //                 fontSize: 20,
          //                 fontWeight: FontWeight.bold,
          //                 color: Colors.white,
          //               ),
          //             ),
          //             const SizedBox(height: 8),
          //             Row(
          //               children: [
          //                 const Icon(
          //                   Icons.calendar_today,
          //                   size: 14,
          //                   color: Colors.white70,
          //                 ),
          //                 const SizedBox(width: 6),
          //                 const Text(
          //                   'Jan 15, 2025',
          //                   style: TextStyle(color: Colors.white70),
          //                 ),
          //                 const SizedBox(width: 16),
          //                 const Icon(
          //                   Icons.location_on,
          //                   size: 14,
          //                   color: Colors.white70,
          //                 ),
          //                 const SizedBox(width: 4),
          //                 const Text(
          //                   'Delhi',
          //                   style: TextStyle(color: Colors.white70),
          //                 ),
          //               ],
          //             ),
          //             const SizedBox(height: 14),
          //             ElevatedButton(
          //               onPressed: () {
          //                 _showRegistrationDialog();
          //               },
          //               style: ElevatedButton.styleFrom(
          //                 backgroundColor: Colors.white,
          //                 foregroundColor: MMPApp.maroon,
          //                 padding: const EdgeInsets.symmetric(
          //                   horizontal: 20,
          //                   vertical: 10,
          //                 ),
          //               ),
          //               child: const Text('Register Now'),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // Tab Bar
          SizedBox(height: 20,),
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
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Events List
          Expanded(
            child: state.isLoading && state.pastEvents.isEmpty && state.upcomingEvents.isEmpty
                ? const Center(child: CircularProgressIndicator(color: MMPApp.maroon))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      state.upcomingEvents.isEmpty ? const Center(child: Text('No upcoming events', style: TextStyle(color: Colors.grey))) : _buildDynamicUpcomingEvents(state.upcomingEvents),
                      state.pastEvents.isEmpty ? const Center(child: Text('No past events', style: TextStyle(color: Colors.grey))) : _buildDynamicPastEvents(state.pastEvents),
                    ],
                  ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: const Text('Suggest event feature coming soon!'),
      //         backgroundColor: MMPApp.maroon,
      //         behavior: SnackBarBehavior.floating,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(10),
      //         ),
      //       ),
      //     );
      //   },
      //   backgroundColor: MMPApp.maroon,
      //   icon: const Icon(Icons.add, color: Colors.white),
      //   label: const Text(
      //     'Suggest Event',
      //     style: TextStyle(color: Colors.white),
      //   ),
      // ),
    );
  }

  Widget _buildDynamicUpcomingEvents(List<Event> events) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: events.length + 1,
      itemBuilder: (context, index) {
        if (index == events.length) return const SizedBox(height: 80);
        final event = events[index];
        final dateStr = '${event.postedDate.day}/${event.postedDate.month}/${event.postedDate.year}';
        return _buildEventCard(
          event: event,
          date: dateStr,
          color: MMPApp.orange,
          isRegistrationOpen: event.status.toLowerCase() == 'active',
        );
      },
    );
  }

  Widget _buildDynamicPastEvents(List<Event> events) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: events.length + 1,
      itemBuilder: (context, index) {
        if (index == events.length) return const SizedBox(height: 80);
        final event = events[index];
        final dateStr = '${event.postedDate.day}/${event.postedDate.month}/${event.postedDate.year}';
        return _buildEventCard(
          event: event,
          date: dateStr,
          color: Colors.grey,
          isRegistrationOpen: false,
          isPastEvent: true,
        );
      },
    );
  }

  Widget _buildEventCard({
    required Event event,
    required String date,
    required Color color,
    required bool isRegistrationOpen,
    bool isPastEvent = false,
  }) {
    final String title = event.name;
    final String description = event.description;
    final String? imageUrl = event.imagePath.isNotEmpty 
        ? event.imagePath 
        : (event.imagePaths.isNotEmpty ? event.imagePaths.first : null);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      ? Icon(Icons.event, color: color, size: 28)
                      : null,
                ),
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
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildEventDetailRow(Icons.calendar_today, date),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (event.srcfStatus.isEmpty) ...[
                if (isPastEvent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history, color: Colors.grey[700], size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Event Ended',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isRegistrationOpen)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Registration Open',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, color: Colors.orange, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Coming Soon',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              const Spacer(),
              if (event.srcfStatus.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade400, width: 0.5),
                  ),
                  child: Text(
                    '${event.srcfStatus[0].toUpperCase()}${event.srcfStatus.substring(1).toLowerCase()}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (event.srcfStatus.isEmpty && !isPastEvent) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRSVPButton(
                  label: 'Accept',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  onPressed: () => _showRSVPDialog(
                    eventId: event.id.toString(),
                    status: 'accepted',
                    themeColor: Colors.green,
                  ),
                ),
                _buildRSVPButton(
                  label: 'Maybe',
                  icon: Icons.help_outline,
                  color: Colors.orange,
                  onPressed: () => _showRSVPDialog(
                    eventId: event.id.toString(),
                    status: 'maybe',
                    themeColor: Colors.orange,
                  ),
                ),
                _buildRSVPButton(
                  label: 'Decline',
                  icon: Icons.cancel_outlined,
                  color: Colors.red,
                  onPressed: () => _showRSVPDialog(
                    eventId: event.id.toString(),
                    status: 'declined',
                    themeColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showRSVPDialog({
    required String eventId,
    required String status,
    required Color themeColor,
  }) async {
    String note = "";
    int adultsCount = 1;
    int childrenCount = 0;
    final state = ref.watch(eventsNotifierProvider);

    final bool isAccepting = status == 'accepted';

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('RSVP: ${status.toUpperCase()}', style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Note (Optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: themeColor, width: 2),
                        ),
                      ),
                      maxLines: 2,
                      onChanged: (value) => note = value,
                    ),
                    if (isAccepting) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const Text("Number of Guests",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _buildCounterRow(
                        label: "Adults",
                        value: adultsCount,
                        onChanged: (val) => setDialogState(() => adultsCount = val!),
                      ),
                      _buildCounterRow(
                        label: "Children",
                        value: childrenCount,
                        onChanged: (val) => setDialogState(() => childrenCount = val!),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: state.isSaving ? null : () {
                    final Map<String, dynamic> data = {
                      "status": status,
                      "note": note,
                    };
                    if (isAccepting) {
                      data["adults_count"] = adultsCount;
                      data["children_count"] = childrenCount;
                    }
                    ref.read(eventsNotifierProvider.notifier).updateRSVP(eventId, data);
                    Navigator.pop(context);
                  },
                  child: state.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCounterRow({
    required String label,
    required int value,
    required ValueChanged<int?> onChanged
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<int>(
              value: value,
              underline: const SizedBox(),
              items: List.generate(11, (i) => i)
                  .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildRSVPButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
