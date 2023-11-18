import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwflutter/src/models/Member.dart';
import 'package:cwflutter/src/models/Project.dart';
import 'package:cwflutter/src/models/Task.dart';
import 'package:cwflutter/src/models/User.dart';
import 'package:flutter/foundation.dart';

class FirestoreService extends ChangeNotifier {
  final db = FirebaseFirestore.instance;


  Future<void> setupProject(Project project) async {
    final projectRef = db.collection('projects').doc(project.project_id.toString());

    final tasksCollection = projectRef.collection('tasks');
    final membersCollection = projectRef.collection('members');

    final projectMap = project.toMap();

    projectRef.set(projectMap);

    project.tasks.forEach((task) { 
      tasksCollection.doc(task.task_id).set(task.toMap());
    });

    project.members.forEach((member) { 
      membersCollection.doc(member.user.user_id.toString()).set(member.toMap());
    });
  }

  Future<void> addMemberToProject(Project project, Member member) async {
    final projectRef = db.collection('projects').doc(project.project_id.toString());
    final membersCollection = projectRef.collection('members');
    await membersCollection.doc(member.user.user_id.toString()).set(member.toMap());
  }

  Future<void> addTaskToProject(Project project, Task task) async {
    final projectRef = db.collection('projects').doc(project.project_id.toString());
    final tasksCollection = projectRef.collection('tasks');
    await tasksCollection.doc(task.task_id).set(task.toMap());
  }

  Future<void> removeMemberFromProject(Project project, Member member) async {
    final projectRef = db.collection('projects').doc(project.project_id.toString());
    final membersCollection = projectRef.collection('members');
    await membersCollection.doc(member.user.user_id.toString()).delete();
  }

  Future<void> removeTaskFromProject(Project project, Task task) async {
    final projectRef = db.collection('projects').doc(project.project_id.toString());
    final tasksCollection = projectRef.collection('tasks');
    await tasksCollection.doc(task.task_id).delete();
  }

  Stream<List<Project>> getUserProjects(User user) {
    List<Project> projectsWithMember = [];
    return db.collection('projects').snapshots().asyncMap(
      (querySnapshot) async {
        for (var project in querySnapshot.docs) { //unoptimized code get rid in the future!
          final membersCollection = project.reference.collection('members');
          final tasksCollection = project.reference.collection('tasks');
          var memberSnapshot = await membersCollection.doc(user.user_id.toString()).get();
          if (memberSnapshot.exists) {
            final newProject = Project.fromMap(project.data());
            var membersSnapshots = await membersCollection.get();
            // Convert each member document to a Member object
            List<Member> members = membersSnapshots.docs.map((doc) {
              return Member.fromMap(doc.data() as Map<String, dynamic>);
            }).toList();
            var tasksSnapshots = await tasksCollection.get();
            // Convert each member document to a Member object
            List<Task> tasks = tasksSnapshots.docs.map((doc) {
              return Task.fromMap(doc.data() as Map<String, dynamic>);
            }).toList();

            newProject.members = members;
            newProject.tasks = tasks;

            projectsWithMember.add(newProject);
          }
        }

        return projectsWithMember;
      },
    );
  }

  Stream<List<Member>> getProjectMembers(Project project) {
    final membersCollection = db.collection('projects').doc(project.project_id.toString()).collection('members');

    return membersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Member.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<Task>> getProjectTasks(Project project) {
    final tasksCollection = db.collection('projects').doc(project.project_id.toString()).collection('tasks');

    return tasksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> updateTask(Project project, Task task) async {
    final projectRef = db.collection('projects').doc(project.project_id.toString());
    final tasksCollection = projectRef.collection('tasks');
    await tasksCollection.doc(task.task_id).set(task.toMap());
  }
}
