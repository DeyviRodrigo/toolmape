import 'package:intl/intl.dart';

/// Variable: _penDot - formato con punto decimal y coma de miles (ej: 1,161,603.57).
final NumberFormat _penDot = NumberFormat('#,##0.00', 'en_US');

/// Función: soles - formatea un número en soles peruanos.
String soles(num v) => 'S/: ${_penDot.format(v)}';
