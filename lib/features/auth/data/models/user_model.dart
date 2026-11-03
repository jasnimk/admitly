import 'package:admitly/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.role,
    super.isVerified = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final role = map['role'] == 'admissionTeam' ? UserRole.admissionTeam : UserRole.parent;
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String? ?? '',
      role: role,
      isVerified: map['isVerified'] as bool? ?? (role == UserRole.parent),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'name': name,
        'role': role == UserRole.admissionTeam ? 'admissionTeam' : 'parent',
        'isVerified': isVerified,
      };
}
