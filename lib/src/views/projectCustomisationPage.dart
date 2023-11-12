import 'dart:async';

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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
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
      length: 3, // Assuming 2 tabs: Members and Tasks
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.project.project_name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Members'),
              Tab(text: 'Tasks'),
              // Add more tabs if needed.
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const SingleChildScrollView(
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
                      height: 400,),
                ],
              ),
            ),
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
                return const Card(
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

            String status = member.status['status'];
            DateTime timestamp = DateTime.fromMillisecondsSinceEpoch((member.status['timestamp']-1) * 1000);
            bool isInScript = status.endsWith('.lua');

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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role),
                    isInScript ? Row(
                      children: [
                        SvgPicture.network(
                          'https://upload.wikimedia.org/wikipedia/commons/5/58/Roblox_Studio_logo_2021_present.svg',  // Replace with the path to your Roblox logo image file
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 5,),
                        Text(member.status['status'], style: TextStyle(color: Colors.blueAccent),)
                      ],
                    ) : Text(member.status['status'], style: TextStyle(color: Colors.blueAccent),),
                    if (isInScript) TaskStatusWidget(startTime: timestamp)
                    
                  ],
                ),
                trailing: (loggedUserRole == Role.Viewer ||
                        member.user.user_id == loggedUser.user_id ||
                        member.role == Role.Owner)
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      MemberRemovalConfirmationScreen(
                                          project: project, member: member));
                            },
                          ),
                        ],
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
class TaskStatusWidget extends StatefulWidget {
  final DateTime startTime;

  TaskStatusWidget({Key? key, required this.startTime}) : super(key: key);

  @override
  _TaskStatusWidgetState createState() => _TaskStatusWidgetState();
}

class _TaskStatusWidgetState extends State<TaskStatusWidget> {
  Timer? _timer;
  Duration _elapsed = Duration();

  void _startTimer() {
    _timer?.cancel(); // Cancel any previous timer
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _elapsed = DateTime.now().difference(widget.startTime);
      });
    });
  }

  @override
  void initState() {
    super.initState();
      _elapsed = DateTime.now().difference(widget.startTime);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format the elapsed duration as hours:minutes:seconds
    String formattedElapsed = DateFormat('HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(_elapsed.inMilliseconds, isUtc: true));

    return
        Text('$formattedElapsed elapsed', style: TextStyle(color: const Color.fromARGB(255, 14, 75, 179)),);
    
  }
}

class MemberRemovalConfirmationScreen extends StatelessWidget {
  final Project project;
  final Member member;

  const MemberRemovalConfirmationScreen(
      {super.key, required this.project, required this.member});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.red.shade900,
      title: const Text("Remove Member", style: TextStyle(color: Colors.white)),
      content: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(member.user.avatar_image),
            backgroundColor: Colors.grey.shade300,
            radius: 20,
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text(
                "Are you sure you want to remove ${member.user.username} from the project?",
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "CANCEL",
              style: TextStyle(color: Colors.white),
            )),
        TextButton(
            onPressed: () {
              Provider.of<ProjectService>(context, listen: false)
                  .removeMemberFromProject(project, member);
              Navigator.pop(context);
            },
            child: const Text(
              "REMOVE",
              style: TextStyle(color: Colors.white),
            )),
      ],
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
                return const Card(
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
                              isEditing: false,
                              task: Task(
                                task_name: "",
                                task_description: "",
                              )),
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
                title: Text(
                  task.task_name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 2),
                      child: Text(task.task_description ?? "N/A"),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (task.assignedTo.length > 0)
                          Row(children: [
                            ...task.assignedTo.map((memberId) {
                              Member member = project.getMemberById(memberId);
                              return CircleAvatar(
                                backgroundImage:
                                    NetworkImage(member.user.avatar_image),
                                backgroundColor: Colors.grey.shade300,
                                radius: 20,
                              );
                            }).toList(),
                            const SizedBox(
                              width: 8,
                            ),
                          ]),
                        if (task.deadline != null)
                          Row(
                            children: [
                              const Icon(Icons.calendar_month),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, right: 4),
                                child: Text(
                                  '${task.deadline.toString().split(' ')[0]}',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: const Text("Mark as Done?"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("CANCEL")),
                                      TextButton(
                                          onPressed: () {
                                            Provider.of<ProjectService>(context,
                                                    listen: false)
                                                .completeTask(project, task);
                                            Navigator.pop(context);
                                          },
                                          child: const Text("OK"))
                                    ],
                                  ));
                        },
                        icon: const Icon(Icons.check_box)),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewTaskPage(
                                      project: project, task: task, isEditing: true,)));
                        },
                        icon: const Icon(Icons.edit)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
