import 'package:cwflutter/src/models/Serializable.dart';

class User implements Serializable {
  final int user_id;
  final String username;
  final String avatar_image;

  User({
    required this.user_id,
    required this.username,
    required this.avatar_image,
    // Additional fields can be passed here
  });
  
  //SERIALISATION FOR FIRESTORE
  @override
  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'username': username,
      'avatar_image': avatar_image,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      user_id: map['user_id'],
      username: map['username'],
      avatar_image: map['avatar_image'],
    );
  }
  //
}