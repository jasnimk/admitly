import 'package:equatable/equatable.dart';

enum UserRole { parent, admissionTeam }

class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  final String uid;
  final String email;
  final String name;
  final UserRole role;

  @override
  List<Object> get props => [uid, email, name, role];
}
