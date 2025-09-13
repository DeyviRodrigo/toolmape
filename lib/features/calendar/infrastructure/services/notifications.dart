import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Clase: NotificationsService - gestiona avisos locales.
class NotificationsService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Función: init - inicializa el plugin de notificaciones.
  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(initSettings);
  }

  /// Función: scheduleOnce - programa una notificación única en la fecha/hora indicada.
  static Future<void> scheduleOnce({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'calendario',
          'Calendario Minero',
          channelDescription: 'Avisos de vencimientos',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // Reemplaza la API deprecada androidAllowWhileIdle
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Función: cancelAll - elimina todas las notificaciones programadas.
  static Future<void> cancelAll() => _plugin.cancelAll();
}

typedef CalendarioNotifications = NotificationsService;
