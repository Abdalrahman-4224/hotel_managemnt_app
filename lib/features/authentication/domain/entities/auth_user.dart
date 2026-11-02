/// The logged-in user, as the rest of the app sees it.
class AuthUser {
  final int id;
  final int? hotelId; // null for a superadmin
  final int? roleId;
  final int? departmentId;
  final String fullName;
  final String username;
  final String roleName;
  final String? phone;
  final String? email;

  const AuthUser({
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

  bool get isAdmin => roleName == 'admin';
}
