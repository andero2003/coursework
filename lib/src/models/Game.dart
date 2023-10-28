import 'package:cwflutter/src/models/Serializable.dart';

class Game implements Serializable {
  final int game_id;
  final String game_title;
  final String game_description;
  final String game_icon;

  Game({
    required this.game_id,
    required this.game_title,
    required this.game_description,
    required this.game_icon,
    // Additional fields can be passed here
  });
  
  //SERIALISATION FOR FIRESTORE
  @override
  Map<String, dynamic> toMap() {
    return {
      'game_id': game_id,
      'game_title': game_title,
      'game_description': game_description,
      'game_icon': game_icon,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      game_id: map['game_id'],
      game_title: map['game_title'],
      game_description: map['game_description'],
      game_icon: map['game_icon'],
    );
  }
  //
}