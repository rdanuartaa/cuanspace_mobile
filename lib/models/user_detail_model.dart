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
    print('Parsing user_detail map: $map'); // Tambahkan log
    return UserDetail(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      userId: map['user_id'] is int
          ? map['user_id']
          : int.tryParse(map['user_id'].toString()),
      profilePhoto: map['profile_photo']?.toString(),
      phone: map['phone']?.toString(),
      address: map['address']?.toString(),
      gender: map['gender']?.toString(),
      dateOfBirth: map['date_of_birth']?.toString(),
      religion: map['religion']?.toString(),
      status: map['status']?.toString(),
    );
  }
}
