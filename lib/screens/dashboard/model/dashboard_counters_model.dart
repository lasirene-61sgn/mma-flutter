class DashboardCountersModel {
  final int newGalleryCount;
  final int newEventCount;
  final int newNewsCount;
  final int newCommitteeCount;
  final int newCustomerCount;

  DashboardCountersModel({
    required this.newGalleryCount,
    required this.newEventCount,
    required this.newNewsCount,
    required this.newCommitteeCount,
    required this.newCustomerCount,
  });

  factory DashboardCountersModel.fromJson(Map<String, dynamic> json) {
    return DashboardCountersModel(
      newGalleryCount: json['new_gallery_count'] ?? 0,
      newEventCount: json['new_event_count'] ?? 0,
      newNewsCount: json['new_news_count'] ?? 0,
      newCommitteeCount: json['new_committee_count'] ?? 0,
      newCustomerCount: json['new_customer_count'] ?? 0,
    );
  }
}
