import 'package:cwflutter/src/models/Member.dart';
import 'package:cwflutter/src/models/Serializable.dart';
import 'package:cwflutter/src/models/Task.dart';
import 'package:cwflutter/src/models/User.dart';

class Project implements Serializable {
  final int project_id;
  final String project_name;
  final String project_image;

  List<Member> members = [];
  List<Task> tasks = [];

  Project({
    required this.project_id,
    required this.project_name,
    required this.project_image
  });

  Member addMember(User user, Role role) {
    Member member = Member(
      user: user, 
      role: role
    );
    members.add(member);
    return member;
  }

  void removeMember(Member member) {
    members.removeWhere((element) => element.user.user_id == member.user.user_id);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'project_id': project_id,
      'project_name': project_name,
      'project_image': project_image,
      'members': members.map((member) => member.toMap()).toList(),
      'tasks': tasks.map((task) => task.toMap()).toList(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      project_id: map['project_id'],
      project_name: map['project_name'],
      project_image: map['project_image'],
    )
    ..members = List<Member>.from(map['members']?.map((x) => Member.fromMap(x)) ?? [])
    ..tasks = List<Task>.from(map['tasks']?.map((x) => Task.fromMap(x)) ?? []);
  }
}