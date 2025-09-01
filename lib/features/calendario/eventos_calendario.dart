import '../../domain/entities/evento_entity.dart';

/// Alias for [EventoEntity] used within calendar features.
typedef EventoCalendar = EventoEntity;

/// Extra helpers for calendar events.
extension EventoCalendarX on EventoEntity {
  /// Whether this event applies to the user given optional [rucDigit] and
  /// [regimen] filters.
  bool aplicaA({int? rucDigit, String? regimen}) {
    final digits = alcance.rucDigits;
    if (digits.isNotEmpty && rucDigit != null && !digits.contains(rucDigit)) return false;
    final regs = alcance.regimen;
    if (regs.isNotEmpty && regimen != null && !regs.contains(regimen)) return false;
    return true;
  }
}

