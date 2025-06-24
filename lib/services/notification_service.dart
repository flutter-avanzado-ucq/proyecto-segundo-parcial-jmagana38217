import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio encargado de configurar y gestionar notificaciones locales
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el sistema de notificaciones, configurando Android, iOS y zona horaria
  static Future<void> initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('ic_notification');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Se inicializan las zonas horarias necesarias para que zonedSchedule funcione correctamente
    tz.initializeTimeZones();

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  /// Método llamado cuando el usuario interactúa con una notificación
  static void _onNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      print('Payload: ${response.payload}');
    }
  }

  /// Solicita permisos al usuario para mostrar notificaciones (Android y iOS)
  static Future<void> requestPermission() async {
    if (await Permission.notification.isDenied ||
        await Permission.notification.isPermanentlyDenied) {
      await Permission.notification.request();
    }

    // Solicita permisos adicionales en iOS
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Muestra una notificación inmediatamente (sin programar)
  static Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Notificaciones Instantáneas',
      channelDescription: 'Canal para notificaciones inmediatas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    // Se genera un ID único usando el timestamp actual
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Programa una notificación para una fecha y hora específicas
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate, // Fecha y hora exacta en que se mostrará la notificación
    required int notificationId,     // ID único que se guarda en la tarea
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Notificaciones Programadas',
      channelDescription: 'Canal para recordatorios de tareas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    // Se usa zonedSchedule para que funcione correctamente según la zona horaria del dispositivo
    await _notificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local), // Convierte la fecha a zona horaria local
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Cancela una notificación programada usando su identificador único
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
