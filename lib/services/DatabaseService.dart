import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseService extends ChangeNotifier {
  final db = FirebaseFirestore.instance;

  Future<void> setupProject(int userId, int gameId) async {
    db.collection('projects')
    .doc(gameId.toString())
    .set({
      'gameId': gameId,
      'owner': userId,
      'users': [userId]
    });
  }

  Future<void> addUserToProject(int userId, int gameId) async {
    db.collection('projects')
    .doc(gameId.toString())
    .update({
      'users': FieldValue.arrayUnion([userId])
    })
    .catchError((onError) => print);
  }

  Future<void> removeUserFromProject(int userId, int gameId) async {
    db.collection('projects')
    .doc(gameId.toString())
    .update({
      'users': FieldValue.arrayRemove([userId])
    })
    .catchError((onError) => print);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserProjects(int userId) {
    return db.collection('projects')
      .where('users', arrayContains: userId)
      .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getProjectStream(int gameId) {
    return db.collection('projects')
      .where('gameId', isEqualTo: gameId)
      .snapshots();
  }
}
