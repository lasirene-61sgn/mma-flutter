class GalleryModel {
  final int id;
  final int adminId;
  final String title;
  final String description;
  final List<String> imagePaths;
  final String status;
  final List<String> videoPaths;
  final DateTime createdAt;
  final DateTime updatedAt;

  GalleryModel({
    required this.id,
    required this.adminId,
    required this.title,
    required this.description,
    required this.imagePaths,
    required this.status,
    required this.videoPaths,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      id: json['id'] ?? 0,
      adminId: json['admin_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imagePaths: (json['image_urls'] as List?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status'] ?? '',
      videoPaths: (json['video_urls'] as List?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admin_id': adminId,
      'title': title,
      'description': description,
      'image_urls': imagePaths,
      'status': status,
      'video_urls': videoPaths,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
