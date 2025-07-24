import 'package:flutter/material.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/holiday_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../provider_task/weather_provider.dart';
import 'provider_task/holiday_provider.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final weatherProvider = Provider.of<WeatherProvider>(context);
    final weather = weatherProvider.weatherData;

    final holidayProvider = Provider.of<HolidayProvider>(context);
    final holidayToday = holidayProvider.todayHoliday;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.greeting,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  localizations.todayTasks,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                if (holidayToday != null)
                  Text(
                      'Hoy es feriado: ${holidayToday.LocalName}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14)
                  ),
                if (weather != null)
                  Row(
                    children: [
                      Image.network(
                        'http://openweathermap.org/img/wn/${weather.iconCode}@2x.png',
                        width: 28,
                        height: 28,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${weather.temperature.toStringAsFixed(1)}ºC - ${weather.description}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                if (weatherProvider.isLoading)
                  const Text(
                    'Cargando clima...',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                if (weatherProvider.errorMessage != null)
                  Text(
                    weatherProvider.errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
