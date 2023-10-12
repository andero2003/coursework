import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHandler {
  final db = FirebaseFirestore.instance;

  Future<void> setupProject(int userId, int gameId) async {
    db.collection('projects')
    .doc(gameId.toString())
    .set({
      'users': [userId]
    });
  }
}