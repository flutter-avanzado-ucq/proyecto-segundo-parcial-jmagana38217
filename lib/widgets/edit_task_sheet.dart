import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider_task/task_provider.dart';
import '../services/notification_service.dart';

/// Pantalla para editar una tarea existente, permitiendo cambiar fecha y hora
class EditTaskSheet extends StatefulWidget {
  final int index;

  const EditTaskSheet({super.key, required this.index});

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  late TextEditingController _controller;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    final task = Provider.of<TaskProvider>(context, listen: false).tasks[widget.index];
    _controller = TextEditingController(text: task.title);

    // Se cargan los valores actuales de la tarea
    _selectedDate = task.dueDate;
    _selectedTime = task.dueTime ?? const TimeOfDay(hour: 8, minute: 0); // Se mantiene la hora programada o se da un valor por defecto
  }

  /// Método que se ejecuta al guardar los cambios
  void _submit() async {
    final newTitle = _controller.text.trim();
    if (newTitle.isNotEmpty) {
      int? notificationId;

      final task = Provider.of<TaskProvider>(context, listen: false).tasks[widget.index];

      // Cancelar la notificación anterior para evitar duplicados
      if (task.notificationId != null) {
        await NotificationService.cancelNotification(task.notificationId!);
      }

      // Mostrar notificación inmediata indicando que se ha editado la tarea
      await NotificationService.showImmediateNotification(
        title: 'Tarea actualizada',
        body: 'Has actualizado la tarea: $newTitle',
        payload: 'Tarea actualizada: $newTitle',
      );

      // Si el usuario seleccionó nueva fecha y hora, programar nueva notificación
      if (_selectedDate != null && _selectedTime != null) {
        final scheduledDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        // Se genera un nuevo identificador de notificación
        notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

        // Se agenda una nueva notificación con los datos actualizados
        await NotificationService.scheduleNotification(
          title: 'Recordatorio de tarea actualizada',
          body: 'No olvides: $newTitle',
          scheduledDate: scheduledDateTime,
          payload: 'Tarea actualizada: $newTitle para $scheduledDateTime',
          notificationId: notificationId,
        );
      }

      // Actualiza la tarea en el proveedor con los nuevos datos
      Provider.of<TaskProvider>(context, listen: false).updateTask(
        widget.index,
        newTitle,
        newDate: _selectedDate,
        newTime: _selectedTime,
        notificationId: notificationId,
      );

      // Cierra el modal
      Navigator.pop(context);
    }
  }

  /// Permite seleccionar una nueva fecha
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Permite seleccionar una nueva hora
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked; // Se actualiza la hora de notificación
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Editar tarea', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickDate,
                child: const Text('Cambiar fecha'),
              ),
              const SizedBox(width: 10),
              if (_selectedDate != null)
                Text('${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickTime,
                child: const Text('Cambiar hora'),
              ),
              const SizedBox(width: 10),
              const Text('Hora: '),
              if (_selectedTime != null)
                Text('${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check),
            label: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}
