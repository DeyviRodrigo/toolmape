/// Value object representing a range between two dates.
class DateRange {
  const DateRange({required this.start, required this.end});

  /// Start of the range.
  final DateTime start;

  /// End of the range.
  final DateTime end;

  /// Returns true if [start] is not after [end].
  bool get isValid => !start.isAfter(end);
}
