import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwflutter/src/models/Member.dart';
import 'package:cwflutter/src/models/Project.dart';
import 'package:cwflutter/src/models/Task.dart';
import 'package:cwflutter/src/models/User.dart';
import 'package:cwflutter/src/services/ProjectService.dart';
import 'package:cwflutter/src/services/RobloxAPIService.dart';
import 'package:cwflutter/src/services/AuthService.dart';
import 'package:cwflutter/src/services/FirestoreService.dart';
import 'package:cwflutter/src/views/newTaskPage.dart';
import 'package:cwflutter/src/views/userSearchPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProjectCustomisationPage extends StatefulWidget {
  final Project project;

  const ProjectCustomisationPage({super.key, required this.project});

  @override
  State<ProjectCustomisationPage> createState() =>
      _ProjectCustomisationPageState();
}

class _ProjectCustomisationPageState extends State<ProjectCustomisationPage> {
  late Stream<List<Member>> membersStream;
  late Stream<List<Task>> tasksStream;
  late Project project = widget.project;

  @override
  void didChangeDependencies() {
    membersStream = Provider.of<FirestoreService>(context)
        .getProjectMembers(widget.project);
    tasksStream =
        Provider.of<FirestoreService>(context).getProjectTasks(widget.project);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Assuming 2 tabs: Members and Tasks
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.project.project_name),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Members'),
              Tab(text: 'Tasks'),
              // Add more tabs if needed.
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Image.network(widget.project.project_thumbnail),
                  //const SizedBox(height: 10,),
                  //const Padding(
                  //  padding: EdgeInsets.all(12.0),
                  //  child: Text("Team", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),),
                  //),
                  SizedBox(
                    height: 400,
                    child: TeamMembersList(
                        membersStream: membersStream, project: project),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 400,
                    child: TasksList(
                      tasksStream: tasksStream,
                      project: project,
                    ),
                  )
                ],
              ),
            ),
            // Add more TabBarView children if you added more tabs.
          ],
        ),
      ),
    );
  }
}

class TeamMembersList extends StatelessWidget {
  const TeamMembersList({
    super.key,
    required this.membersStream,
    required this.project,
  });

  final Stream<List<Member>> membersStream;
  final Project project;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Member>>(
      stream: membersStream,
      builder: (BuildContext context, AsyncSnapshot<List<Member>> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: SizedBox(
                        height: 30, child: CircularProgressIndicator()),
                  ),
                );
              });
        }
        final List<Member> members = snapshot.data!;
        return ListView.builder(
          itemCount: members.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(left: 6, right: 6),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserSearchPage(
                            project: project,
                          ),
                        ));
                  },
                  style: Theme.of(context).elevatedButtonTheme.style,
                  child: const Text("Add Member"),
                ),
              );
            }
            Member member = members[index - 1];
            String username = member.user.username;
            String avatar_image = member.user.avatar_image;
            String role = member.role.toShortString();

            User loggedUser =
                Provider.of<AuthService>(context, listen: false).loggedUser!;
            Member loggedMember =
                Provider.of<ProjectService>(context, listen: false)
                    .getMemberFromUser(project, loggedUser)!;
            Role loggedUserRole = loggedMember.role;
            return Card(
              color: Theme.of(context).listTileTheme.textColor,
              child: ListTile(
                leading: CircleAvatar(
                    radius: 30, backgroundImage: NetworkImage(avatar_image)),
                title: Text(
                  username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(role),
                trailing: (loggedUserRole == Role.Viewer ||
                        member.user.user_id == loggedUser.user_id ||
                        member.role == Role.Owner)
                    ? null
                    : IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          Provider.of<ProjectService>(context, listen: false)
                              .removeMemberFromProject(project, member);
                        },
                      ),
              ),
            );
          },
        );
      },
    );
  }
}

class TasksList extends StatelessWidget {
  const TasksList({
    super.key,
    required this.tasksStream,
    required this.project,
  });

  final Stream<List<Task>> tasksStream;
  final Project project;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: tasksStream,
      builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: SizedBox(
                        height: 30, child: CircularProgressIndicator()),
                  ),
                );
              });
        }
        final List<Task> tasks = snapshot.data!;
        return ListView.builder(
          itemCount: tasks.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(left: 6, right: 6),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewTaskPage(
                            project: project,
                          ),
                        ));
                  },
                  style: Theme.of(context).elevatedButtonTheme.style,
                  child: const Text("Add Task"),
                ),
              );
            }
            Task task = tasks[index - 1];
            return Card(
              child: ListTile(
                title: Text(task.task_name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.task_description ?? "N/A"),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.calendar_month),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4),
                          child: Text(
                            '${task.deadline.toString().split(' ')[0]}',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
              ),
            );
          },
        );
      },
    );
  }
}
