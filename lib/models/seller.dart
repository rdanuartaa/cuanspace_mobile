class Seller {
  final int id;
  final String brandName;
  final String description;
  final String address;
  final String contactEmail;
  final String contactWhatsapp;
  final String? profileImage;
  final String? bannerImage;

  Seller({
    required this.id,
    required this.brandName,
    required this.description,
    required this.address,
    required this.contactEmail,
    required this.contactWhatsapp,
    this.profileImage,
    this.bannerImage,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'],
      brandName: json['brand_name'],
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      contactWhatsapp: json['contact_whatsapp'] ?? '',
      profileImage: json['profile_image'],
      bannerImage: json['banner_image'],
    );
  }
}