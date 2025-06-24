import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/edit_task_sheet.dart';

/// Tarjeta visual que representa una tarea en la lista.
/// Muestra título, estado (hecha o no), fecha y hora de vencimiento (si existen),
/// y permite editar o eliminar la tarea.
class TaskCard extends StatelessWidget {
  final String title;
  final bool isDone;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Animation<double> iconRotation;
  final DateTime? dueDate;    // Fecha en que debe notificarse la tarea
  final TimeOfDay? dueTime;   // Hora específica de la notificación
  final int index;

  const TaskCard({
    super.key,
    required this.title,
    required this.isDone,
    required this.onToggle,
    required this.onDelete,
    required this.iconRotation,
    required this.index,
    this.dueDate,
    this.dueTime,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isDone ? 0.4 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFD0F0C0) : const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ListTile(
          leading: GestureDetector(
            onTap: onToggle,
            child: AnimatedBuilder(
              animation: iconRotation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: iconRotation.value * pi,
                  child: Icon(
                    isDone ? Icons.refresh : Icons.radio_button_unchecked,
                    color: isDone ? Colors.teal : Colors.grey,
                    size: 30,
                  ),
                );
              },
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Muestra el título de la tarea
              Text(
                title,
                style: TextStyle(
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  fontSize: 18,
                  color: isDone ? Colors.black45 : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Si la tarea tiene fecha, mostrarla
              if (dueDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Vence: ${DateFormat('dd/MM/yyyy').format(dueDate!)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      // Si también tiene hora, mostrarla
                      if (dueTime != null)
                        Text(
                          'Hora: ${dueTime!.hour.toString().padLeft(2, '0')}:${dueTime!.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón para editar la tarea (permite cambiar fecha/hora y reprogramar notificación)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => EditTaskSheet(index: index),
                  );
                },
              ),
              // Botón para eliminar la tarea (también cancela su notificación si tiene)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
