import 'package:flutter/material.dart';

import 'package:toolmape/features/general/presentation/shared/menu_option.dart';

/// Actions related to discount calculations.
enum DescuentoAction { ayuda, desdePrecio, predeterminado }

/// Menu options for [DescuentoAction].
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
