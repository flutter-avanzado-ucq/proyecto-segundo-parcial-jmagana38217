import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Pantalla y providers
import 'package:flutter_animaciones_notificaciones/screens/settings_screen.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/theme_provider.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/locale_provider.dart';

void main() {
  testWidgets('SettingsScreen muestra opciones de idioma y tema',
      (WidgetTester tester) async {
    // Crea el widget de prueba incluyendo los providers requeridos
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
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
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle(); // Espera a que se renderice todo

    // ✅ Verifica si aparece el texto para cambiar idioma (está en el widget)
    expect(find.text('Idioma / Language'), findsAtLeastNWidgets(1));

    // ✅ Verifica si el botón para cambiar tema está presente (ícono)
    expect(find.byIcon(Icons.dark_mode), findsWidgets); // Ajusta según el tema por defecto
  });
}
