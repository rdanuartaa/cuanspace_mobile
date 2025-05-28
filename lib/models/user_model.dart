import 'package:cuan_space/models/user_detail_model.dart';

class User {
  int? id;
  String? name;
  String? email;
  UserDetail? userDetail;

  User({
    this.id,
    this.name,
    this.email,
    this.userDetail,
  });

  // Konstruktor untuk kompatibilitas dengan main.dart
  User.required({
    required this.id,
    required this.name,
    required this.email,
    this.userDetail,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'user_detail': userDetail?.toMap(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String?,
      email: map['email'] as String?,
      userDetail: map['user_detail'] != null
          ? UserDetail.fromMap(map['user_detail'] as Map<String, dynamic>)
          : null,
    );
  }
}
