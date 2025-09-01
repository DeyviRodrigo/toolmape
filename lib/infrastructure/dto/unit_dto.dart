class UnitDto {
  final String code;
  final String name;
  final double? ratioToGram;

  UnitDto({
    required this.code,
    required this.name,
    required this.ratioToGram,
  });

  factory UnitDto.fromJson(Map<String, dynamic> json) => UnitDto(
        code: json['code'] as String,
        name: json['name'] as String,
        ratioToGram: json['ratio_to_gram'] == null
            ? null
            : (json['ratio_to_gram'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'ratio_to_gram': ratioToGram,
      };
}
