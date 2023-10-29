import 'package:cwflutter/src/models/Game.dart';
import 'package:cwflutter/src/models/Member.dart';
import 'package:cwflutter/src/models/Project.dart';
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
      project_icon: game.game_icon,
      project_thumbnail: game.game_thumbnail
    );
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
    if (member.role == Role.Owner) { return; }
    project.removeMember(member);
    _firestoreService.removeMemberFromProject(project, member);
  }
}
