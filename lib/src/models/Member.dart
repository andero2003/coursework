import 'package:cwflutter/src/models/Serializable.dart';
import 'package:cwflutter/src/models/User.dart';

enum Role { Viewer, Developer, Owner }

extension RoleExtension on Role {
  String toShortString() {
    return this.toString().split('.').last;
  }

  static Role fromString(String role) {
    return Role.values.firstWhere((r) => r.toShortString() == role);
  }
}

class Member implements Serializable {
  final User user;
  final Role role;

  Member({
    required this.user,
    required this.role,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'user': user.toMap(),
      'role': role.toShortString(),
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      user: User.fromMap(map['user']),
      role: RoleExtension.fromString(map['role']),
    );
  }
}