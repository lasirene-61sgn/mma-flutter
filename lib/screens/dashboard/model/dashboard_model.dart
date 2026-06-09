class BirthdayModel {
  final int id;
  final String name;
  final String mobile;
  final String? whatsapp;
  final DateTime? anniversaryDate;
  final DateTime? dateOfBirth;
  final int? villageId;
  final String? area;
  final Village? village;
  final String? image;
  final String? fatherName;
  final String? gotra;
  final String? msFirmName;
  final String? city;
  final String? email;
  final int? age;
  final String? gender;
  final String? businessType;
  final String? businessName;
  final String? productService;
  final String? officeAddress;
  final String? education;
  final String? occupation;
  final String? bloodGroup;
  final String? hobbies;
  final String? nativePlace;
  final bool isToday;

  BirthdayModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.whatsapp,
    this.anniversaryDate,
    this.dateOfBirth,
    this.villageId,
    this.area,
    this.village,
    this.image,
    this.fatherName,
    this.gotra,
    this.msFirmName,
    this.city,
    this.email,
    this.age,
    this.gender,
    this.businessType,
    this.businessName,
    this.productService,
    this.officeAddress,
    this.education,
    this.occupation,
    this.bloodGroup,
    this.hobbies,
    this.nativePlace,
    this.isToday = false,
  });

  factory BirthdayModel.fromJson(Map<String, dynamic> json) {
    return BirthdayModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      whatsapp: json['whatsapp'],
      anniversaryDate: json['anniversary_date'] != null
          ? DateTime.tryParse(json['anniversary_date'])
          : null,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      villageId: json['village_id'],
      area: json['area'],
      village: json['village'] != null ? Village.fromJson(json['village']) : null,
      image: json['image'],
      fatherName: json['father_name'],
      gotra: json['gotra'],
      msFirmName: json['ms_firm_name'],
      city: json['city'],
      email: json['email'],
      age: json['age'] is int ? json['age'] : (json['age'] != null ? int.tryParse(json['age'].toString()) : null),
      gender: json['gender'],
      businessType: json['business_type'],
      businessName: json['business_name'],
      productService: json['product_service'],
      officeAddress: json['office_address'],
      education: json['education'],
      occupation: json['occupation'],
      bloodGroup: json['blood_group'],
      hobbies: json['hobbies'],
      nativePlace: json['native_place'],
      isToday: json['is_birthday_today'] == true || json['is_anniversary_today'] == true,
    );
  }

  BirthdayModel copyWith({
    int? id,
    String? name,
    String? mobile,
    String? whatsapp,
    DateTime? anniversaryDate,
    DateTime? dateOfBirth,
    int? villageId,
    String? area,
    Village? village,
    String? image,
    String? fatherName,
    String? gotra,
    String? msFirmName,
    String? city,
    String? email,
    int? age,
    String? gender,
    String? businessType,
    String? businessName,
    String? productService,
    String? officeAddress,
    String? education,
    String? occupation,
    String? bloodGroup,
    String? hobbies,
    String? nativePlace,
    bool? isToday,
  }) {
    return BirthdayModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      whatsapp: whatsapp ?? this.whatsapp,
      anniversaryDate: anniversaryDate ?? this.anniversaryDate,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      villageId: villageId ?? this.villageId,
      area: area ?? this.area,
      village: village ?? this.village,
      image: image ?? this.image,
      fatherName: fatherName ?? this.fatherName,
      gotra: gotra ?? this.gotra,
      msFirmName: msFirmName ?? this.msFirmName,
      city: city ?? this.city,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      businessType: businessType ?? this.businessType,
      businessName: businessName ?? this.businessName,
      productService: productService ?? this.productService,
      officeAddress: officeAddress ?? this.officeAddress,
      education: education ?? this.education,
      occupation: occupation ?? this.occupation,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      hobbies: hobbies ?? this.hobbies,
      nativePlace: nativePlace ?? this.nativePlace,
      isToday: isToday ?? this.isToday,
    );
  }
}

class Village {
  final int id;
  final String name;

  Village({
    required this.id,
    required this.name,
  });

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Village copyWith({
    int? id,
    String? name,
  }) {
    return Village(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

class DonateModel {
  final int id;
  final int adminId;
  final String image;
  final String? appUrl;
  final String createdAt;
  final String updatedAt;
  final String imageUrl;

  DonateModel({
    required this.id,
    required this.adminId,
    required this.image,
    this.appUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.imageUrl,
  });

  factory DonateModel.fromJson(Map<String, dynamic> json) {
    return DonateModel(
      id: json['id'] ?? 0,
      adminId: json['admin_id'] ?? 0,
      image: json['image'] ?? '',
      appUrl: json['app_url'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }

  DonateModel copyWith({
    int? id,
    int? adminId,
    String? image,
    String? appUrl,
    String? createdAt,
    String? updatedAt,
    String? imageUrl,
  }) {
    return DonateModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      image: image ?? this.image,
      appUrl: appUrl ?? this.appUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class SocialLinksModel {
  final String? facebookLink;
  final String? whatsappLink;
  final String? instagramLink;
  final String? linkedinLink;
  final String? twitterLink;
  final String? emailLink;
  final String? youtubeLink;

  SocialLinksModel({
    this.facebookLink,
    this.whatsappLink,
    this.instagramLink,
    this.linkedinLink,
    this.twitterLink,
    this.emailLink,
    this.youtubeLink,
  });

  factory SocialLinksModel.fromJson(Map<String, dynamic> json) {
    return SocialLinksModel(
      facebookLink: json['facebook_link'],
      whatsappLink: json['whatsapp_link'],
      instagramLink: json['instagram_link'],
      linkedinLink: json['linkedin_link'],
      twitterLink: json['twitter_link'],
      emailLink: json['email_link'],
      youtubeLink: json['youtube_link'],
    );
  }

  SocialLinksModel copyWith({
    String? facebookLink,
    String? whatsappLink,
    String? instagramLink,
    String? linkedinLink,
    String? twitterLink,
    String? emailLink,
    String? youtubeLink,
  }) {
    return SocialLinksModel(
      facebookLink: facebookLink ?? this.facebookLink,
      whatsappLink: whatsappLink ?? this.whatsappLink,
      instagramLink: instagramLink ?? this.instagramLink,
      linkedinLink: linkedinLink ?? this.linkedinLink,
      twitterLink: twitterLink ?? this.twitterLink,
      emailLink: emailLink ?? this.emailLink,
      youtubeLink: youtubeLink ?? this.youtubeLink,
    );
  }
}
