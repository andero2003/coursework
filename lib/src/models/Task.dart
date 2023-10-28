import 'package:cwflutter/src/models/Member.dart';
import 'package:cwflutter/src/models/Serializable.dart';

enum TaskStatus { Pending, InProgress, Completed, Rejected }

extension TaskStatusExtension on TaskStatus {
  String toShortString() {
    return this.toString().split('.').last;
  }

  static TaskStatus fromString(String status) {
    return TaskStatus.values.firstWhere((r) => r.toShortString() == status);
  }
}

class Task implements Serializable {
  final int task_id;
  final String task_name;

  String? task_description;
  DateTime? deadline;

  List<Member> assignedTo = [];
  TaskStatus status = TaskStatus.Pending;

  Task({
    required this.task_id,
    required this.task_name,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'task_id': task_id,
      'task_name': task_name,
      'task_description': task_description,
      'deadline': deadline?.millisecondsSinceEpoch,
      'assignedTo': assignedTo.map((member) => member.toMap()).toList(),
      'status': status.toShortString(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      task_id: map['task_id'],
      task_name: map['task_name'],
    )
    ..task_description = map['task_description']
    ..deadline = map['deadline'] != null ? DateTime.fromMillisecondsSinceEpoch(map['deadline']) : null
    ..assignedTo = List<Member>.from(map['assignedTo']?.map((x) => Member.fromMap(x)) ?? [])
    ..status = TaskStatusExtension.fromString(map['status']);
  }
}