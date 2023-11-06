import 'package:cwflutter/src/models/Project.dart';
import 'package:cwflutter/src/models/Task.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class TaskCustomisationScreen extends StatelessWidget {
  final Project project;
  final Task task;

  const TaskCustomisationScreen(
      {super.key, required this.project, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.task_name),
      ),
      body: Placeholder(),
    );
  }
}
