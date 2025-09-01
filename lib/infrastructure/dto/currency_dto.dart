class CurrencyDto {
  final String code;
  final String name;
  final String? symbol;
  final int decimals;

  CurrencyDto({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimals,
  });

  factory CurrencyDto.fromJson(Map<String, dynamic> json) => CurrencyDto(
        code: json['code'] as String,
        name: json['name'] as String,
        symbol: json['symbol'] as String?,
        decimals: (json['decimals'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'symbol': symbol,
        'decimals': decimals,
      };
}
