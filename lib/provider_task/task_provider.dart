import 'package:flutter/material.dart';
import '../services/notification_service.dart';

/// Modelo de tarea con campos adicionales para notificaciones programadas
class Task {
  String title;
  bool done;

  /// Fecha en la que se debe mostrar la notificación
  DateTime? dueDate;

  /// Hora en la que se debe mostrar la notificación
  TimeOfDay? dueTime; // Se agregó para permitir especificar la hora exacta junto con la fecha

  /// Identificador único de la notificación programada
  int? notificationId; // Se agregó para poder identificar y cancelar notificaciones cuando sea necesario

  Task({
    required this.title,
    this.done = false,
    this.dueDate,
    this.dueTime,
    this.notificationId,
  });
}

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Agrega una nueva tarea con fecha, hora e ID de notificación
  void addTask(String title, {DateTime? dueDate, TimeOfDay? dueTime, int? notificationId}) {
    _tasks.insert(0, Task(
      title: title,
      dueDate: dueDate,
      dueTime: dueTime,
      notificationId: notificationId,
    ));
    notifyListeners();
  }

  /// Marca una tarea como completada o no completada
  void toggleTask(int index) {
    _tasks[index].done = !_tasks[index].done;
    notifyListeners();
  }

  /// Elimina una tarea y cancela su notificación programada si existe
  void removeTask(int index) {
    final task = _tasks[index];

    // Cancelar la notificación asociada antes de eliminar la tarea
    if (task.notificationId != null) {
      NotificationService.cancelNotification(task.notificationId!);
    }

    _tasks.removeAt(index);
    notifyListeners();
  }

  /// Actualiza una tarea y cancela su notificación anterior antes de programar una nueva
  void updateTask(int index, String newTitle, {DateTime? newDate, TimeOfDay? newTime, int? notificationId}) {
    final task = _tasks[index];

    // Cancelar notificación anterior antes de asignar una nueva
    if (task.notificationId != null) {
      NotificationService.cancelNotification(task.notificationId!);
    }

    _tasks[index].title = newTitle;
    _tasks[index].dueDate = newDate;
    _tasks[index].dueTime = newTime;
    _tasks[index].notificationId = notificationId;

    notifyListeners();
  }
}
