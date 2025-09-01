/// Value object representing event applicability filters.
class EventScope {
  const EventScope({
    this.rucDigits = const [],
    this.regimen = const [],
  });

  /// List of RUC last digits the event applies to.
  final List<int> rucDigits;

  /// List of regimen identifiers the event applies to.
  final List<String> regimen;

  /// Creates an [EventScope] from a JSON map.
  factory EventScope.fromJson(Map<String, dynamic>? json) {
    json ??= const {};
    return EventScope(
      rucDigits: (json['ruc_digits'] as List?)?.map((e) => e as int).toList() ?? const [],
      regimen: (json['regimen'] as List?)?.map((e) => e as String).toList() ?? const [],
    );
  }

  /// Converts this scope into a JSON map.
  Map<String, dynamic> toJson() => {
        if (rucDigits.isNotEmpty) 'ruc_digits': rucDigits,
        if (regimen.isNotEmpty) 'regimen': regimen,
      };
}
