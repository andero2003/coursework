import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwflutter/pages/projectCustomisationPage.dart';
import 'package:cwflutter/services/DatabaseService.dart';
import 'package:cwflutter/classes/GameData.dart';
import 'package:cwflutter/classes/GameParser.dart';
import 'package:cwflutter/classes/User.dart';
import 'package:cwflutter/pages/newProjectPage.dart';
import 'package:cwflutter/services/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  final User user;

  DashboardPage({required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {   
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [IconButton(
          icon: Icon(Icons.logout), onPressed: () {
            final authService = Provider.of<AuthService>(context, listen: false);
            authService.logout();
          },
        )],
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16,16,16,4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: NetworkImage(widget.user.avatarUrl),
                            backgroundColor: Colors.grey.shade300,
                            radius: 40,
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Welcome, ${widget.user.username}!',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 1.5,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: DatabaseService().getUserProjects(widget.user.id),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData) {
                          return Text('No projects found');
                        } else {
                          final relevantData = snapshot.data!.docs.map((e) => e.data()).toList();
                          return ProjectsGrid(projects: relevantData);
                        }
                      },
                    ),
                  ),
                ),
            ])
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: FloatingActionButton(
              elevation: 10,
              tooltip: 'New Project',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NewProjectPage(userId: widget.user.id)
                  )
                );
              }, 
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_outlined, size: 24,),
                ],
              )
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectsGrid extends StatefulWidget {
  final List projects;

  const ProjectsGrid({
    super.key,
    required this.projects
  });

  @override
  State<ProjectsGrid> createState() => _ProjectsGridState();
}

class _ProjectsGridState extends State<ProjectsGrid> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.projects.length,
      itemBuilder: (context, index) {
        final gameId = widget.projects[index]['gameId'];
        final mediaFuture = GameParser().fetchGameMedia(gameId);

        final GameData gameData = GameData(id: gameId);

        return GameCardButton(
          gameData: gameData, 
          mediaFuture: mediaFuture,
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => ProjectCustomisationPage(gameData: gameData),
              )
            );
          },
        );
      },
    );
  }
}

class GameCardButton extends StatelessWidget {
  final GameData gameData;
  final Future<FetchResult> mediaFuture;
  final Function() onPressed;

  const GameCardButton({
    super.key,
    required this.gameData,
    required this.mediaFuture,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: MaterialButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        color: Colors.grey.shade300,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: FutureBuilder(
                  future: mediaFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      String url = snapshot.data!.data['data'][0]['imageUrl'];
                      return Image.network(
                        url,
                        fit: BoxFit.fitHeight,
                        height: 128,
                      );
                    } else {
                      return Container(
                        color: Colors.grey.shade400,
                        height: 128,
                        width: 128,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  }
                ),
              ),
            ),
            Flexible(
              child: FutureBuilder(
                future: GameParser().fetchGameInfo(gameData.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [                
                        Text(
                          snapshot.data!.data['data'][0]['name'] ?? 'N/A',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5,),
                        Text(
                          snapshot.data!.data['data'][0]['description'] ?? 'N/A',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [                
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            color: Colors.grey.shade400,
                            width: 128,
                            height: 18,
                          ),
                        ),
                        SizedBox(height: 10,),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            color: Colors.grey.shade400,
                            width: 200,
                            height: 18,
                          ),
                        ),
                      ],
                    );
                  }
                }
              ),
            )
          ],
        )
      ),
    );
  }
}
