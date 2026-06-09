class BannerModel {
  final int id;
  final int adminId;
  final String imagePath;
  final String imageUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BannerModel({
    required this.id,
    required this.adminId,
    required this.imagePath,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      adminId: json['admin_id'] ?? 0,
      imagePath: json['image_path_url'] ?? json['image_path'] ?? '',
      imageUrl: json['image_path_url'] ?? json['image_path'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admin_id': adminId,
      'image_path': imagePath,
      'image_path_url': imageUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BannerModel copyWith({
    int? id,
    int? adminId,
    String? imagePath,
    String? imageUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status.toLowerCase() == 'active';
}
