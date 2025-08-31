import '../../domain/entities/evento_entity.dart';

/// Alias for [EventoEntity] used within calendar features.
typedef EventoCalendar = EventoEntity;

/// Extra helpers for calendar events.
extension EventoCalendarX on EventoEntity {
  /// Whether this event applies to the user given optional [rucDigit] and
  /// [regimen] filters.
  bool aplicaA({int? rucDigit, String? regimen}) {
    final digits = (alcance['ruc_digits'] as List?)?.cast<int>();
    if (digits != null && digits.isNotEmpty && rucDigit != null &&
        !digits.contains(rucDigit)) return false;
    final regs = (alcance['regimen'] as List?)?.cast<String>();
    if (regs != null && regs.isNotEmpty && regimen != null &&
        !regs.contains(regimen)) return false;
    return true;
  }
}

