import 'package:cwflutter/src/models/FetchResult.dart';
import 'package:cwflutter/src/models/Project.dart';
import 'package:cwflutter/src/models/Task.dart';
import 'package:cwflutter/src/models/User.dart';
import 'package:cwflutter/src/services/ProjectService.dart';
import 'package:cwflutter/src/services/RobloxAPIService.dart';
import 'package:cwflutter/src/services/FirestoreService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewTaskPage extends StatefulWidget {
  final Project project;

  const NewTaskPage({super.key, required this.project});

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  String title = 'N/A';
  String description = 'N/A';
  DateTime? deadline;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add Task"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Task Title',
                ),
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Task Description',
                ),
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DeadlineField(onDateSelected: (DateTime date) {
                setState(() {
                  deadline = date;
                });
              }),
            ),
            ElevatedButton(
              onPressed: () {
                if (deadline == null) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Image.network(
                            "https://t4.ftcdn.net/jpg/05/08/38/47/360_F_508384795_AaOb8TQgvq6BqOCbMXtAgEKZJofEXPOn.jpg",
                            height: 64,
                          ),
                          content: Text("Please fill out all the fields!"),
                        );
                      });
                  return;
                }
                Task task = Task(
                    task_id: 1,
                    task_name: title,
                    task_description: description,
                    deadline: deadline);
                Provider.of<ProjectService>(context, listen: false)
                    .addTaskToProject(widget.project, task);
                Navigator.pop(context);
              },
              style: Theme.of(context).elevatedButtonTheme.style,
              child: const Text("Add Task"),
            ),
          ],
        ));
  }
}

class DeadlineField extends StatefulWidget {
  final Function(DateTime) onDateSelected; // Callback function

  DeadlineField({required this.onDateSelected});

  @override
  _DeadlineFieldState createState() => _DeadlineFieldState();
}

class _DeadlineFieldState extends State<DeadlineField> {
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });

      widget.onDateSelected(picked); // Call the callback with the selected date
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.calendar_today, color: Colors.grey),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedDate == null
                    ? 'Set Deadline'
                    : 'Deadline: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
