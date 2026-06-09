import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmp_official/main.dart'; // For MMPApp colors
import 'package:mmp_official/screens/dashboard/notifier/dashboard_notifier.dart';
import 'package:mmp_official/screens/dashboard/model/notifiction_model.dart';
import 'package:intl/intl.dart';

class NotificationBottomSheet extends ConsumerStatefulWidget {
  const NotificationBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationBottomSheet(),
    );
  }

  @override
  ConsumerState<NotificationBottomSheet> createState() => _NotificationBottomSheetState();
}

class _NotificationBottomSheetState extends ConsumerState<NotificationBottomSheet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardNotifierProvider.notifier).loadNotification());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardNotifierProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MMPApp.maroon,
                      ),
                    ),
                    if (state.notification.isNotEmpty)
                      TextButton(
                        onPressed: state.isSaving
                            ? null
                            : () async {
                                await ref.read(dashboardNotifierProvider.notifier).loadNotificationPost();
                              },
                        child: state.isSaving
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Mark all read'),
                      ),
                  ],
                ),
              ),
              const Divider(),
              
              // Content
              Expanded(
                child: state.isLoading && state.notification.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.notification.isEmpty
                        ? const Center(
                            child: Text(
                              'No new notifications',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(20),
                            itemCount: state.notification.length,
                            itemBuilder: (context, index) {
                              final notification = state.notification[index];
                              return _buildNotificationItem(notification);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    final bool isUnread = !notification.isRead;
    final color = isUnread ? MMPApp.maroon : Colors.grey;
    final String timeString = notification.createdAt != null
        ? DateFormat.yMMMd().add_jm().format(notification.createdAt!)
        : 'Just now';

    return InkWell(
      onTap: () {
        if (isUnread && notification.id != null) {
          ref.read(dashboardNotifierProvider.notifier).loadSingleNotificationPost(notification.id!.toString());
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnread ? color.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread ? color.withValues(alpha: 0.2) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUnread ? color.withValues(alpha: 0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isUnread ? Icons.notifications_active : Icons.notifications_none,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                            color: isUnread ? Colors.black : Colors.grey.shade800,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: MMPApp.maroon,
                            shape: BoxShape.circle,
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUnread ? Colors.grey[700] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeString,
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
}
