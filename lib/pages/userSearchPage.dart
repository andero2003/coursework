import 'package:cwflutter/classes/GameData.dart';
import 'package:cwflutter/classes/GameParser.dart';
import 'package:cwflutter/classes/User.dart';
import 'package:cwflutter/services/DatabaseService.dart';
import 'package:flutter/material.dart';

class UserSearchPage extends StatefulWidget {
  final int gameId;

  const UserSearchPage({
    super.key, required this.gameId,
  });

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  late List results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Member"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search by Username',
              ),
              onSubmitted: (value) async {
                final result = await GameParser().searchUsers(value);
                if (result.status == ResultStatus.success) {
                  setState(() {
                    results = result.data['data'];
                  });
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final user = results[index];
                if (user != null) {
                  return Card(
                    child: ListTile(
                      title: Text(user['name']),
                      subtitle: Text("User ID: ${user['id']}"),
                      trailing: IconButton(
                        onPressed: (){
                          DatabaseService().addUserToProject(user['id'], widget.gameId);
                          Navigator.pop(context);
                        }, 
                        icon: Icon(Icons.add, color: Colors.green,)
                      ),
                    ),
                  );
                }
              },
            )
          )
        ],
      )
    );
  }
}