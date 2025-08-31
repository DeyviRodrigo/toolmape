import 'package:flutter/material.dart';

import 'menu_option.dart';

/// Actions for law (purity) calculations.
enum LeyAction { ayuda, predeterminado }

/// Menu options for [LeyAction].
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
