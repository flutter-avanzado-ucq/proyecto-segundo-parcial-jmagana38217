import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Servicios simulados y widget
import 'package:flutter_animaciones_notificaciones/widgets/header.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/holiday_provider.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/weather_provider.dart';
import 'package:flutter_animaciones_notificaciones/services/weather_service.dart';
import 'package:flutter_animaciones_notificaciones/services/holiday_service.dart';

// Fake Providers para prueba sin red
class FakeWeatherProvider extends WeatherProvider {
  @override
  WeatherData? get weatherData => WeatherData(
        temperature: 25.5,
        description: 'Soleado',
        cityName: 'Querétaro',
        iconCode: '01d',
      );

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;
}

class FakeHolidayProvider extends HolidayProvider {
  @override
  Holiday? get todayHoliday => Holiday(
        localName: 'Día de prueba',
        date: DateTime.now(),
      );
}

void main() {
  setUpAll(() => HttpOverrides.global = _NoNetworkHttpOverrides());

  testWidgets('Header muestra feriado y clima correctamente', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FakeWeatherProvider()),
          ChangeNotifierProvider(create: (_) => FakeHolidayProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es')],
          locale: const Locale('es'),
          home: const Scaffold(
            body: Header(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(); // Espera que se construya el widget

    // ✅ Verifica que el texto del feriado se muestra
    expect(find.textContaining('Día de prueba'), findsOneWidget);

    // ✅ Verifica que la temperatura simulada aparece
    expect(find.textContaining('25.5'), findsOneWidget);

    // ✅ Verifica la descripción del clima
    expect(find.textContaining('Soleado'), findsOneWidget);
  });
}

class _NoNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    throw UnsupportedError('No se permiten peticiones HTTP en pruebas');
  }
}
