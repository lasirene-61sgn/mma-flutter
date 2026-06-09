class MmpctCategory {
  final int id;
  final String categoryName;

  MmpctCategory({
    required this.id,
    required this.categoryName,
  });

  factory MmpctCategory.fromJson(Map<String, dynamic> json) {
    return MmpctCategory(
      id: json['id'] ?? 0,
      categoryName: json['category_name'] ?? json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_name': categoryName,
    };
  }
}

class MmpctMember {
  final int supportCategoryId;
  final String name;
  final String phone;
  final String image;

  MmpctMember({
    required this.supportCategoryId,
    required this.name,
    required this.phone,
    required this.image,
  });

  factory MmpctMember.fromJson(Map<String, dynamic> json) {
    return MmpctMember(
      supportCategoryId: json['support_category_id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image_url'] ?? json['image_path_url'] ?? json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'support_category_id': supportCategoryId,
      'name': name,
      'phone': phone,
      'image': image,
    };
  }

  MmpctMember copyWith({
    int? supportCategoryId,
    String? name,
    String? phone,
    String? image,
  }) {
    return MmpctMember(
      supportCategoryId: supportCategoryId ?? this.supportCategoryId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      image: image ?? this.image,
    );
  }
}
