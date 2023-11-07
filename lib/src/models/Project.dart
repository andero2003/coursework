import 'package:cwflutter/src/models/Member.dart';
import 'package:cwflutter/src/models/Serializable.dart';
import 'package:cwflutter/src/models/Task.dart';
import 'package:cwflutter/src/models/User.dart';

class Project implements Serializable {
  final int project_id;
  final String project_name;
  final String project_icon;
  final String project_thumbnail;

  List<Member> members = [];
  List<Task> tasks = [];

  Project(
      {required this.project_id,
      required this.project_name,
      required this.project_icon,
      required this.project_thumbnail});

  Member addMember(User user, Role role) {
    Member member = Member(user: user, role: role);
    members.add(member);
    return member;
  }

  void removeMember(Member member) {
    members
        .removeWhere((element) => element.user.user_id == member.user.user_id);
  }

  void completeTask(Task task) {
    tasks.removeWhere((element) => element.task_id == task.task_id);
  }

  Member getMemberById(int id) {
    for (Member member in members) {
      if (member.user.user_id == id) {
        return member;
      }
    }
    throw Exception();
  }

  void addTask(Task task) {
    tasks.add(task);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'project_id': project_id,
      'project_name': project_name,
      'project_icon': project_icon,
      'project_thumbnail': project_thumbnail,
      'members': members.map((member) => member.toMap()).toList(),
      'tasks': tasks.map((task) => task.toMap()).toList(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
        project_id: map['project_id'],
        project_name: map['project_name'],
        project_icon: map['project_icon'],
        project_thumbnail: map['project_thumbnail'])
      ..members =
          List<Member>.from(map['members']?.map((x) => Member.fromMap(x)) ?? [])
      ..tasks =
          List<Task>.from(map['tasks']?.map((x) => Task.fromMap(x)) ?? []);
  }
}
