import 'package:cwflutter/src/models/Game.dart';
import 'package:cwflutter/src/models/Member.dart';
import 'package:cwflutter/src/models/Project.dart';
import 'package:cwflutter/src/models/Task.dart';
import 'package:cwflutter/src/models/User.dart';
import 'package:cwflutter/src/services/AuthService.dart';
import 'package:cwflutter/src/services/FirestoreService.dart';
import 'package:flutter/foundation.dart';

class ProjectService extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  ProjectService(this._authService, this._firestoreService);

  Future<void> initialiseProjectForGame(Game game) async {
    User loggedUser = _authService.loggedUser!;
    Project project = Project(
        project_id: game.game_id,
        project_name: game.game_title,
        project_description: game.game_description,
        project_icon: game.game_icon,
        project_thumbnail: game.game_thumbnail);
    project.addMember(loggedUser, Role.Owner);
    _firestoreService.setupProject(project);
  }

  Member? getMemberFromUser(Project project, User user) {
    for (Member member in project.members) {
      if (member.user.user_id == user.user_id) {
        return member;
      }
    }
    return null;
  }

  Stream<List<Member>> getProjectMembers(Project project) {
    return _firestoreService.getProjectMembers(project);
  }

  Future<void> addUserToProject(Project project, User user) async {
    Member member = project.addMember(user, Role.Viewer);
    _firestoreService.addMemberToProject(project, member);
  }

  Future<void> removeMemberFromProject(Project project, Member member) async {
    if (member.role == Role.Owner) {
      return;
    }
    project.removeMember(member);
    _firestoreService.removeMemberFromProject(project, member);
  }

  Future<void> completeTask(Project project, Task task) async {
    project.completeTask(task);
    _firestoreService.removeTaskFromProject(project, task);
  }

  Future<void> addTaskToProject(Project project, Task task) async {
    project.addTask(task);
    _firestoreService.addTaskToProject(project, task);
  }

  Future<void> updateTask(Project project, Task task) async {
    int taskIndex = project.tasks.indexWhere((element) => element.task_id == task.task_id);
    project.tasks[taskIndex] = task;
    _firestoreService.updateTask(project, task);
  }
}
