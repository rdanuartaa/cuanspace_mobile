class UserDetail {
  int? id;
  int? userId;
  String? profilePhoto;
  String? phone;
  String? address;
  String? gender;
  String? dateOfBirth;
  String? religion;
  String? status;

  UserDetail({
    this.id,
    this.userId,
    this.profilePhoto,
    this.phone,
    this.address,
    this.gender,
    this.dateOfBirth,
    this.religion,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'profile_photo': profilePhoto,
      'phone': phone,
      'address': address,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'religion': religion,
      'status': status,
    };
  }

  factory UserDetail.fromMap(Map<String, dynamic> map) {
    return UserDetail(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      profilePhoto: map['profile_photo'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      gender: map['gender'] as String?,
      dateOfBirth: map['date_of_birth'] as String?,
      religion: map['religion'] as String?,
      status: map['status'] as String?,
    );
  }
}