import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwflutter/src/models/Member.dart';
import 'package:cwflutter/src/models/Project.dart';
import 'package:cwflutter/src/models/User.dart';
import 'package:flutter/foundation.dart';

class FirestoreService extends ChangeNotifier {
  final db = FirebaseFirestore.instance;

  Future<void> setupProject(Project project) async {
    await db.collection('projects')
    .doc(project.project_id.toString())
    .set(project.toMap());
  }

  Future<void> addMemberToProject(Project project, Member member) async {
    await db.collection('projects')
    .doc(project.project_id.toString())
    .update({
      'members': FieldValue.arrayUnion([member.toMap()])
    });
  }

  Future<void> removeMemberFromProject(Project project, Member member) async {
    await db.collection('projects')
    .doc(project.project_id.toString())
    .update({
      'members': FieldValue.arrayRemove([member.toMap()])
    });
  }

  Stream<List<Project>> getUserProjects(User user) {
    return db.collection('projects').snapshots().asyncMap(
      (querySnapshot) {
        final filteredDocs = querySnapshot.docs.where(
          (doc) {
            List members = doc['members'] as List;
            return members.any(
              (member) => (member['user'] as Map)['user_id'] == user.user_id
            );
          },
        ).toList();

        return filteredDocs.map(
          (doc) => Project.fromMap(doc.data())
        ).toList();
      },
    );
  }

  Stream<List<Member>> getProjectMembers(Project project) {
    return db.collection('projects')
    .doc(project.project_id.toString())
    .snapshots()
    .asyncMap((snapshot) {
        List<Member> members = [];
        var membersData = snapshot.data()?['members'] as List? ?? [];
        for (var memberData in membersData) {
          members.add(Member.fromMap(memberData as Map<String, dynamic>));
        }
        return members;
    });
  }
}
