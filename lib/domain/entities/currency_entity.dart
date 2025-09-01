class CurrencyEntity {
  final String code;
  final String name;
  final String? symbol;
  final int decimals;

  CurrencyEntity({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimals,
  });
}
