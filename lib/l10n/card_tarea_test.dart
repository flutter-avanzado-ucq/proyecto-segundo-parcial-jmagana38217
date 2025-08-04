import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_animaciones_notificaciones/widgets/card_tarea.dart';

void main() {
  testWidgets('TaskCard muestra el título y estado correctamente', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es')],
        locale: const Locale('es'),
        home: Scaffold(
          body: TaskCard(
            key: const ValueKey('task1'),
            title: 'Hacer tarea',
            isDone: false,
            dueDate: DateTime(2025, 8, 10), // ✅ Obligatorio
            onToggle: () {},                // ✅ Obligatorio
            onDelete: () {},                // ✅ Obligatorio
            iconRotation: AnimationController(
              vsync: const TestVSync(),
              duration: const Duration(milliseconds: 500),
            ), // Simulación del controlador
            index: 0,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // ✅ Valida que el texto de la tarea aparece
    expect(find.text('Hacer tarea'), findsOneWidget);

    // ✅ Checkbox presente y no marcado
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isFalse);
  });
}

// ✅ Vsync de prueba para AnimationController
class TestVSync implements TickerProvider {
  const TestVSync();
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
