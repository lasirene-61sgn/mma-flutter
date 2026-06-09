class TeamMember {
  final int id;
  final int adminId;
  final String name;
  final String phone;
  final String postName;
  final int sortOrder;
  final String? imagePath;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  TeamMember({
    required this.id,
    required this.adminId,
    required this.name,
    required this.phone,
    required this.postName,
    required this.sortOrder,
    this.imagePath,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] ?? 0,
      adminId: json['admin_id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone']?.toString() ?? '',
      postName: json['post_name'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
      imagePath: json['image_path_url'] ?? json['image_path'],
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admin_id': adminId,
      'name': name,
      'phone': phone,
      'post_name': postName,
      'sort_order': sortOrder,
      'image_path': imagePath,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
