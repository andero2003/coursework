import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHandler {
  final db = FirebaseFirestore.instance;

  Future<void> setupProject(int userId, int gameId) async {
    db.collection('projects')
    .doc(gameId.toString())
    .set({
      'gameId': gameId,
      'users': [userId]
    });
  }

  Future<QuerySnapshot<Map>> getUserProjects(int userId) async {
    return 
      db.collection('projects')
      .where('users', arrayContains: userId)
      .get();
  }
}