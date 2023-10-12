import 'package:cwflutter/classes/DatabaseHandler.dart';
import 'package:cwflutter/classes/GameParser.dart';
import 'package:cwflutter/pages/authWebViewPage.dart';
import 'package:cwflutter/pages/newProjectPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  final String username;
  final String avatarUrl;
  final int userId;

  DashboardPage({required this.username, required this.avatarUrl, required this.userId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {   
    List<Widget> _widgetOptions = <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.avatarUrl),
                    backgroundColor: Colors.grey.shade300,
                    radius: 40,
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Welcome, ${widget.username}!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Divider(
                thickness: 1.5,
              ),
              /*
              Text("Current Project", style:TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Image(
                    height: 56,
                    image: NetworkImage('https://tr.rbxcdn.com/d74dabd69b700545ad692135943d3794/150/150/Image/Png'),
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Balloon Simulator',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              SizedBox(height: 5),

              Divider(
                thickness: 1.5,
              ),
              */
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
            future: DatabaseHandler().getUserProjects(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final relevantData = snapshot.data!.docs.map((e) => e.data()).toList();
                return ProjectsGrid(userId: widget.userId, projects: relevantData);
              }
            }
          ),
        )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        }, 
        currentIndex: _selectedIndex,
        items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Projects',
            ),         
        ]
      ),
    );
  }
}

class ProjectsGrid extends StatefulWidget {
  final int userId;
  final List projects;

  const ProjectsGrid({
    super.key,
    required this.userId,
    required this.projects
  });

  @override
  State<ProjectsGrid> createState() => _ProjectsGridState();
}

class _ProjectsGridState extends State<ProjectsGrid> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.projects.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NewProjectPage(userId: widget.userId)
                )
              );
            }, 
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_outlined, size: 100,),
                Text("Setup New Project", style: TextStyle(fontSize: 24),)
              ],
            )
          );
        }

        print(widget.projects);
        print(index);
        final gameId = widget.projects[index - 1]['gameId'];
        final mediaFuture = GameParser().fetchGameMedia(gameId);

        return Card(
          child: FutureBuilder(
            future: mediaFuture, 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data?.status == ResultStatus.failure) {
                return const Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 64,),
                        SizedBox(height: 10,),
                      ],
                    ),
                  )
                );
              } else {
                String url = snapshot.data!.data['data'][0]['imageUrl'];
                return Column(
                  children: [
                    //Text(game['name'], textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    Image.network(
                      url,
                      fit: BoxFit.fitWidth,
                    ),
                  ],
                );
              }                          
            }
          ),
        );
      },
    );
  }
}
