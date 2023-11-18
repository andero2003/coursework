import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwflutter/src/models/Game.dart';
import 'package:cwflutter/src/models/Project.dart';
import 'package:cwflutter/src/services/RobloxAPIService.dart';
import 'package:cwflutter/src/models/User.dart';
import 'package:cwflutter/src/services/FirestoreService.dart';
import 'package:cwflutter/src/services/AuthService.dart';
import 'package:cwflutter/src/services/ThemeService.dart';
import 'package:cwflutter/src/views/NewProjectPage.dart';
import 'package:cwflutter/src/views/projectCustomisationPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/FetchResult.dart';

class DashboardPage extends StatefulWidget {
  final User user;

  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {   
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [IconButton(
          icon: const Icon(Icons.logout), onPressed: () {
            final authService = Provider.of<AuthService>(context, listen: false);
            authService.logout();
          },
        )],
      ),
      drawer: const Drawer(
          child: Column(
            children: [
              SizedBox(
                height: 64,
              ),
              DarkModeSwitch()
            ],
          )
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
                            backgroundImage: NetworkImage(widget.user.avatar_image),
                            backgroundColor: Colors.grey.shade300,
                            radius: 40,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            'Welcome, ${widget.user.username}!',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 1.5,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder<List<Project>>(
                      stream: Provider.of<FirestoreService>(context).getUserProjects(widget.user),
                      builder: (BuildContext context, AsyncSnapshot<List<Project>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData) {
                          return const Text('No projects found');
                        } else {
                          List<Project> projects = snapshot.data!;
                          return ProjectsGrid(projects: projects);
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
                    builder: (context) => const NewProjectPage()
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

class DarkModeSwitch extends StatefulWidget {
  const DarkModeSwitch({
    super.key,
  });

  @override
  State<DarkModeSwitch> createState() => _DarkModeSwitchState();
}

class _DarkModeSwitchState extends State<DarkModeSwitch> {
  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    bool isDarkMode = themeService.getThemeMode() == ThemeMode.dark;

    return ListTile(
      title: Text("Dark Mode"),
      leading: Switch(
        value: isDarkMode, 
        onChanged: (value) {
          isDarkMode = value;
          if (value) {
            themeService.setThemeMode(ThemeMode.dark);
          } else {
            themeService.setThemeMode(ThemeMode.light);          
          }
        }
      )
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
        final Project project = widget.projects[index];
        final Game game = Game(
          game_id: project.project_id, 
          game_title: project.project_name, 
          game_description: project.project_description, 
          game_icon: project.project_icon,
          game_thumbnail: project.project_thumbnail
        );
        return GameCardButton(
          game: game,
          onPressed: () {
            //Navigator.push(
            //  context, 
            //  MaterialPageRoute(
            //    builder: (context) => ProjectCustomisationPage(project: project),
            //  )
            //);
            showModalBottomSheet(
              context: context, 
              isScrollControlled: true,
              builder: (context) => ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                child: ProjectCustomisationPage(project: project)
              ),
            );
          },
        );
      },
    );
  }
}

class GameCardButton extends StatelessWidget {
  final Game game;
  final Function() onPressed;

  const GameCardButton({
    super.key,
    required this.game,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: MaterialButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        color: Theme.of(context).cardColor,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  game.game_icon,
                  fit: BoxFit.fitHeight,
                  height: 128,
                )
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                
                  Text(
                    game.game_title,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5,),
                  Text(
                    game.game_description,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              )
            )
          ],
        )
      ),
    );
  }
}
