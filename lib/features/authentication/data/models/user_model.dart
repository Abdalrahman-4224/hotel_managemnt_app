import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/auth_user.dart';

/// The `user` object from the server, with JSON conversion.
class UserModel {
  final int id;
  final int? hotelId;
  final int? roleId;
  final int? departmentId;
  final String fullName;
  final String username;
  final String roleName;
  final String? phone;
  final String? email;

  const UserModel({
    required this.id,
    required this.hotelId,
    required this.roleId,
    required this.departmentId,
    required this.fullName,
    required this.username,
    required this.roleName,
    required this.phone,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: parseInt(json['user_id'])!,
      hotelId: parseInt(json['hotel_id']),
      roleId: parseInt(json['role_id']),
      departmentId: parseInt(json['department_id']),
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      roleName: json['role_name'] ?? '',
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'hotel_id': hotelId,
      'role_id': roleId,
      'department_id': departmentId,
      'full_name': fullName,
      'username': username,
      'role_name': roleName,
      'phone': phone,
      'email': email,
    };
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      hotelId: hotelId,
      roleId: roleId,
      departmentId: departmentId,
      fullName: fullName,
      username: username,
      roleName: roleName,
      phone: phone,
      email: email,
    );
  }
}
