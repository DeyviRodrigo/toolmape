/// Utilities for parsing numeric values.
///
/// Provides [parseDouble] which is tolerant to commas as decimal separators.
/// Returns `null` if the input cannot be parsed.

double? parseDouble(String? value) {
  if (value == null) return null;
  return double.tryParse(value.replaceAll(',', '.'));
}
