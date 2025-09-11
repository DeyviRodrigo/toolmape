class MetalDto {
  final String code;
  final String description;
  final String defaultUnitCode;
  final String chemicalSymbol;

  MetalDto({
    required this.code,
    required this.description,
    required this.defaultUnitCode,
    required this.chemicalSymbol,
  });

  factory MetalDto.fromJson(Map<String, dynamic> json) => MetalDto(
        code: json['code'] as String,
        description: json['description'] as String,
        defaultUnitCode: json['default_unit_code'] as String,
        chemicalSymbol: json['chemical_symbol'] as String,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        'default_unit_code': defaultUnitCode,
        'chemical_symbol': chemicalSymbol,
      };
}
