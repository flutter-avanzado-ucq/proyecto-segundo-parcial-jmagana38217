import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool done;

  @HiveField(2)
  DateTime? dueDate;

  @HiveField(3)
  int notificationId;


  TaskModel({
    required this.title,
    this.done = false,
    required this.dueDate,
    required this.notificationId,
  });
}
