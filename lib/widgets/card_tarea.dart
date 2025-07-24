import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formato de fecha
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart'; // Asegúrate de importar esto si usas context.watch
import '../provider_task/holiday_provider.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final bool isDone;
  final DateTime? dueDate;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final AnimationController iconRotation;
  final int index;

  const TaskCard({
    super.key,
    required this.title,
    required this.isDone,
    required this.dueDate,
    required this.onToggle,
    required this.onDelete,
    required this.iconRotation,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final holidays = context.watch<HolidayProvider>().holidays;
    final isHoliday = dueDate != null &&
        holidays != null &&
        holidays.any((h) =>
            h.date.year == dueDate!.year &&
            h.date.month == dueDate!.month &&
            h.date.day == dueDate!.day);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: isDone,
                onChanged: (_) => onToggle(),
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (dueDate != null)
            Builder(
              builder: (context) {
                final locale = Localizations.localeOf(context).languageCode;
                final formattedDate = DateFormat.yMMMMd(locale).format(dueDate!);
                final translatedDueDate =
                    localizations.dueDate(formattedDate);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translatedDueDate,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                    if (isHoliday)
                      Text(
                        localizations.holidayTag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
