import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio de notificaciones locales (recordatorios de deudas)
class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Timezones para programar con precisión
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_localTimezoneName()));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    // Pedir permisos donde aplique
    await _requestPermissionsIfNeeded();

    _initialized = true;
  }

  // ---------- Programación específica para Deudas ----------

  Future<void> scheduleForDebt({
    required String debtId,
    required String title,
    required DateTime dueDate,
  }) async {
    await init();

    // Cancelamos previamente para evitar duplicados
    await cancelForDebt(debtId);

    // Tres notificaciones: -1 día, 0 días, +1 día (vencido)
    final base = debtId.hashCode & 0x7fffffff;
    final dayBefore = _atHour(dueDate.subtract(const Duration(days: 1)), 9);
    final sameDay = _atHour(dueDate, 9);
    final overDue = _atHour(dueDate.add(const Duration(days: 1)), 9);

    final androidDetails = AndroidNotificationDetails(
      'debts_channel',
      'Recordatorios de deudas',
      channelDescription:
          'Notifica los vencimientos de las deudas registradas en la app',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Helper safe schedule (solo si es futuro)
    Future<void> _safeSchedule(int id, String body, DateTime when) async {
      final now = DateTime.now();
      if (when.isBefore(now)) return;
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(when, tz.local),
          details,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
      } catch (e, s) {
        if (kDebugMode) {
          debugPrint(
            'NotificationsService: fallo al programar recordatorio '
            'para deuda $debtId (id $id) en $when: $e',
          );
          debugPrint('$s');
        }
      }
    }

    await _safeSchedule(
      base,
      'Mañana vence tu pago. No olvides cumplir a tiempo.',
      dayBefore,
    );
    await _safeSchedule(
      base + 1,
      'Hoy es la fecha de pago. Te recomendamos pagarlo hoy.',
      sameDay,
    );
    await _safeSchedule(
      base + 2,
      'El pago está vencido desde ayer. Regulariza para evitar intereses.',
      overDue,
    );
  }

  Future<void> cancelForDebt(String debtId) async {
    await init();
    final base = debtId.hashCode & 0x7fffffff;
    await _plugin.cancel(base);
    await _plugin.cancel(base + 1);
    await _plugin.cancel(base + 2);
  }

  // ---------- Utilidades ----------

  Future<void> _requestPermissionsIfNeeded() async {
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      // En Android 13+ es necesario pedir permiso
      await android?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  DateTime _atHour(DateTime base, int hour) {
    return DateTime(base.year, base.month, base.day, hour);
  }

  String _localTimezoneName() {
    // Fallback simple: devuelve la zona local del sistema.
    // tz.guessLocalTimezone() no está expuesto; usamos nombre común.
    try {
      return tz.local.name;
    } catch (_) {
      return 'UTC';
    }
  }
}
