import 'package:cwflutter/src/models/FetchResult.dart';
import 'package:cwflutter/src/models/Project.dart';
import 'package:cwflutter/src/models/Task.dart';
import 'package:cwflutter/src/models/User.dart';
import 'package:cwflutter/src/services/ProjectService.dart';
import 'package:cwflutter/src/services/RobloxAPIService.dart';
import 'package:cwflutter/src/services/FirestoreService.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
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
  List<int> assignedTo = [];
  DateTime? deadline;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _deadlineController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add Task"),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter task title';
                    }
                    return null;
                  },
                  onSaved: (value) => title = value ?? '',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Task Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter task description';
                    }
                    return null;
                  },
                  onSaved: (value) => description = value ?? '',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FormField<DateTime>(
                  builder: (FormFieldState<DateTime> state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              String formattedDate =
                                  pickedDate.toString().split(' ')[0];
                              _deadlineController.text = formattedDate;
                              setState(() {
                                deadline = pickedDate;
                              });
                              state.didChange(pickedDate);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(4),
                              labelText: 'Select deadline',
                              errorText:
                                  state.hasError ? state.errorText : null,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              prefixIcon: Icon(Icons.calendar_today),
                              // If you also need suffix icon you can add like this
                              // suffixIcon: Icon(Icons.arrow_drop_down),
                            ),
                            baseStyle: TextStyle(fontSize: 16.0),
                            child: TextFormField(
                              controller: _deadlineController,
                              decoration: InputDecoration(
                                hintText: 'YYYY-MM-DD',
                                border: InputBorder.none,
                              ),
                              readOnly: true,
                              validator: (val) {
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MultiSelectDropDown(
                      hint: 'Assign To Members',
                      borderRadius: 5,
                      borderWidth: 1,
                      borderColor: Colors.grey,
                      optionsBackgroundColor: Colors.transparent,
                      dropdownHeight: 100,
                      backgroundColor: Color.fromARGB(0, 0, 0, 0),
                      optionTextStyle:
                          TextStyle(color: Theme.of(context).hintColor),
                      onOptionSelected: ((selectedOptions) {
                        setState(() {
                          assignedTo = selectedOptions
                              .map((e) => int.parse(e.value!))
                              .toList();
                        });
                      }),
                      options: widget.project.members
                          .map((member) => ValueItem(
                              label: member.user.username,
                              value: member.user.user_id.toString()))
                          .toList())),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Task task = Task(
                        task_id: 1,
                        task_name: title,
                        task_description: description,
                        deadline: deadline);
                    task.assignedTo = assignedTo;
                    Provider.of<ProjectService>(context, listen: false)
                        .addTaskToProject(widget.project, task);
                    Navigator.pop(context);
                  }
                },
                style: Theme.of(context).elevatedButtonTheme.style,
                child: const Text("Add Task"),
              ),
            ],
          ),
        ));
  }
}
