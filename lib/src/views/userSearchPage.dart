import 'package:cwflutter/src/models/FetchResult.dart';
import 'package:cwflutter/src/models/Project.dart';
import 'package:cwflutter/src/models/User.dart';
import 'package:cwflutter/src/services/ProjectService.dart';
import 'package:cwflutter/src/services/RobloxAPIService.dart';
import 'package:cwflutter/src/services/FirestoreService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserSearchPage extends StatefulWidget {
  final Project project;

  const UserSearchPage({
    super.key, required this.project
  });

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  late List<User> results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Member"),
      ),
      body: Column(
        
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search by Username',
              ),
              onSubmitted: (value) async {
                final result = await RobloxAPIService().searchUsers(value);
                if (result.status == ResultStatus.success) {
                  setState(() {
                    results = result.data!;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final User user = results[index];
                return Card(
                  child: ListTile(
                    title: Text(user.username),
                    subtitle: Text("User ID: ${user.user_id}"),
                    trailing: IconButton(
                      onPressed: (){
                        Provider.of<ProjectService>(context, listen: false).addUserToProject(widget.project, user);
                        Navigator.pop(context);
                      }, 
                      icon: const Icon(Icons.add, color: Colors.green,)
                    ),
                  ),
                );
              },
            )
          )
        ],
       
      )
    );
  }
}