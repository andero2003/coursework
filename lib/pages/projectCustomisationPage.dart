import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwflutter/classes/GameData.dart';
import 'package:cwflutter/classes/GameParser.dart';
import 'package:cwflutter/pages/userSearchPage.dart';
import 'package:cwflutter/services/AuthService.dart';
import 'package:cwflutter/services/DatabaseService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProjectCustomisationPage extends StatefulWidget {
  final GameData gameData;

  const ProjectCustomisationPage({
    super.key,
    required this.gameData
  });

  @override
  State<ProjectCustomisationPage> createState() => _ProjectCustomisationPageState();
}

class _ProjectCustomisationPageState extends State<ProjectCustomisationPage> {
  late Stream<QuerySnapshot> projectStream;

  @override
  void initState() {
    // TODO: implement initState
    projectStream = DatabaseService().getProjectStream(widget.gameData.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("Team", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),),
          ),
          SizedBox(
            height: 300,
            child: StreamBuilder<QuerySnapshot>(
              stream: projectStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                int ownerId = 0;
                List<int> users = [];
                if (snapshot.data?.docs != null && snapshot.data!.docs.isNotEmpty) {
                  users = List<int>.from(snapshot.data!.docs.first.get('users') ?? []);
                  ownerId = snapshot.data!.docs.first.get('owner');
                }
                return ListView.builder(
                  itemCount: users.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 6, right: 6),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => UserSearchPage(gameId: widget.gameData.id),));
                          }, 
                          child: Text("Add Member"),
                        ),
                      );
                    }
                    int userId = users[index - 1];
                    final userInfo = GameParser().getUserInfo(userId);
                    final userIcon = GameParser().getUserIcons([userId]);
                    bool isOwner = userId == ownerId;
                    final authService = Provider.of<AuthService>(context);
                    bool hasPermissions = authService.loggedUser != null && authService.loggedUser!.id == ownerId;
                    print(authService.loggedUser);
                    return Card(
                      color: Colors.grey.shade200,
                      child: ListTile(
                        leading: FutureBuilder(
                          future: userIcon,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final icon = snapshot.data!.data['data'][0]['imageUrl'];
                              return CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(icon)
                              );
                            } else {
                              return Container(
                                color: Colors.grey.shade300,
                                width: 60,
                                height: 60,
                              );
                            }
                          }
                        ),
                        title: FutureBuilder(
                          future: userInfo,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final username = snapshot.data!.data['name'];
                              return Text(username ?? "N/A", style: TextStyle(fontWeight: FontWeight.bold),);
                            }
                            return Container(
                              color: Colors.grey.shade300,
                              width: 80,
                              height: 15,
                            );
                          }
                        ),
                        subtitle: Text(isOwner ? "Owner" : "Developer"),
                        trailing: isOwner || !hasPermissions ? null : IconButton(
                          icon: Icon(Icons.delete, color: Colors.red,), 
                          onPressed: () {  
                            DatabaseService().removeUserFromProject(userId, widget.gameData.id);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            )
          ),

        ]
      ),
    );
  }
}