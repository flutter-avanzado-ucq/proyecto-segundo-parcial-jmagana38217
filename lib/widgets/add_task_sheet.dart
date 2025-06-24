import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider_task/task_provider.dart';
import '../services/notification_service.dart';

/// Pantalla modal para agregar una nueva tarea, incluyendo fecha y hora programada
class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _controller = TextEditingController();

  /// Variable para guardar la fecha seleccionada por el usuario
  DateTime? _selectedDate;

  /// Variable para guardar la hora seleccionada por el usuario
  TimeOfDay? _selectedTime; // Se agregó para que el usuario pueda elegir la hora exacta de la notificación

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Método que se ejecuta al presionar "Agregar tarea"
  void _submit() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      int? notificationId;

      // Muestra una notificación inmediata para confirmar que la tarea fue agregada
      await NotificationService.showImmediateNotification(
        title: 'Nueva tarea',
        body: 'Has agregado la tarea: $text',
        payload: 'Tarea: $text',
      );

      // Si el usuario seleccionó fecha y hora, programar una notificación futura
      if (_selectedDate != null && _selectedTime != null) {
        final scheduledDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        // Se genera un identificador único para la notificación
        notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

        // Programar la notificación con fecha y hora seleccionadas
        await NotificationService.scheduleNotification(
          title: 'Recordatorio de tarea',
          body: 'No olvides: $text',
          scheduledDate: scheduledDateTime,
          payload: 'Tarea programada: $text para $scheduledDateTime',
          notificationId: notificationId,
        );
      }

      // Guardar la tarea en el proveedor con los datos completos
      Provider.of<TaskProvider>(context, listen: false).addTask(
        text,
        dueDate: _selectedDate,
        dueTime: _selectedTime,           // Se guarda la hora seleccionada en la tarea
        notificationId: notificationId,   // También se guarda el ID para futuras cancelaciones
      );

      // Cerrar el modal
      Navigator.pop(context);
    }
  }

  /// Muestra el selector de fecha
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Muestra el selector de hora
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked; // Hora elegida por el usuario
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
          const Text('Agregar nueva tarea', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickDate,
                child: const Text('Seleccionar fecha'),
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
                child: const Text('Seleccionar hora'),
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
            label: const Text('Agregar tarea'),
          ),
        ],
      ),
    );
  }
}
