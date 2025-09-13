import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toolmape/features/calendar/infrastructure/services/notifications.dart';
import 'package:toolmape/features/calendar/domain/usecases/schedule_notifications_usecase.dart';

final scheduleNotificationsProvider = Provider<ScheduleNotifications>((ref) {
  return ScheduleNotifications(
    cancelAll: NotificationsService.cancelAll,
    scheduleOnce: NotificationsService.scheduleOnce,
  );
});
