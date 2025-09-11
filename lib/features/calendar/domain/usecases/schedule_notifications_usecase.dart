import '../entities/evento_entity.dart';

typedef _CancelAll = Future<void> Function();
typedef _ScheduleOnce = Future<void> Function({
  required int id,
  required DateTime when,
  required String title,
  required String body,
});

/// Use case to schedule local notifications for calendar events.
class ScheduleNotifications {
  ScheduleNotifications({
    required _CancelAll cancelAll,
    required _ScheduleOnce scheduleOnce,
  })  : _cancelAll = cancelAll,
        _scheduleOnce = scheduleOnce;

  final _CancelAll _cancelAll;
  final _ScheduleOnce _scheduleOnce;

  Future<void> call({
    required List<EventoEntity> eventos,
    required int? rucLastDigit,
    required String? regimen,
    required bool isWeb,
  }) async {
    if (isWeb) return;

    await _cancelAll();
    int id = 3000;
    DateTime at0900(DateTime d) => DateTime(d.year, d.month, d.day, 9);

    for (final e in eventos) {
      if (!_aplicaA(e, rucLastDigit, regimen)) continue;

      if (e.recordatorio != null && e.recordatorio!.isAfter(DateTime.now())) {
        await _scheduleOnce(
          id: id++,
          when: at0900(e.recordatorio!),
          title: e.titulo,
          body: 'Recordatorio (${e.categoria ?? 'Obligación'})',
        );
      }
      if (e.inicio != null && e.inicio!.isAfter(DateTime.now())) {
        await _scheduleOnce(
          id: id++,
          when: at0900(e.inicio!),
          title: e.titulo,
          body: 'Inicio de plazo (${e.categoria ?? 'Obligación'})',
        );
      }
      if (e.fin != null && e.fin!.isAfter(DateTime.now())) {
        await _scheduleOnce(
          id: id++,
          when: at0900(e.fin!),
          title: e.titulo,
          body: 'Fin de plazo (${e.categoria ?? 'Obligación'})',
        );
      }
    }
  }

  bool _aplicaA(EventoEntity e, int? rucDigit, String? regimen) {
    final digits = e.alcance.rucDigits;
    if (digits.isNotEmpty && rucDigit != null && !digits.contains(rucDigit)) return false;
    final regs = e.alcance.regimen;
    if (regs.isNotEmpty && regimen != null && !regs.contains(regimen)) return false;
    return true;
  }
}
