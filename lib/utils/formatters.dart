import 'package:intl/intl.dart';

// Formato con punto decimal y coma de miles (ej: 1,161,603.57)
final NumberFormat _penDot = NumberFormat('#,##0.00', 'en_US');

String soles(num v) => 'S/: ${_penDot.format(v)}';
