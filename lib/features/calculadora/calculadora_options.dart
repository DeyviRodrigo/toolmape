import 'package:flutter/material.dart';

class MenuOption<T> {
  final T value;
  final String label;
  final IconData icon;
  const MenuOption({required this.value, required this.label, required this.icon});
}

enum GeneralAction { actualizar, avanzadas, personalizados }
enum DescuentoAction { ayuda, desdePrecio, predeterminado }
enum LeyAction { ayuda, predeterminado }

const generalMenuOptions = <MenuOption<GeneralAction>>[
  MenuOption(
      value: GeneralAction.actualizar,
      label: 'Actualizar datos',
      icon: Icons.sync
  ),
  MenuOption(
      value: GeneralAction.avanzadas,
      label: 'Opciones avanzadas',
      icon: Icons.tune
  ),
  MenuOption(
      value: GeneralAction.personalizados,
      label: 'Valores personalizados',
      icon: Icons.edit
  ),
];

const descuentoMenuOptions = <MenuOption<DescuentoAction>>[
  MenuOption(
    value: DescuentoAction.ayuda,
    label: 'Ayúdame a calcular el descuento',
    icon: Icons.live_help_outlined,
  ),
  MenuOption(
    value: DescuentoAction.desdePrecio,
    label: 'Tengo el precio, calcular descuento',
    icon: Icons.price_change,
  ),
  MenuOption(
    value: DescuentoAction.predeterminado,
    label: 'Usar valores por defecto',
    icon: Icons.settings_suggest,
  ),
];

const leyMenuOptions = <MenuOption<LeyAction>>[
  MenuOption(
    value: LeyAction.ayuda,
    label: 'Ayúdame a calcular la ley',
    icon: Icons.live_help_outlined,
  ),
  MenuOption(
    value: LeyAction.predeterminado,
    label: 'Usar valores por defecto',
    icon: Icons.verified_outlined,
  ),
];
