import 'package:flutter/material.dart';

import 'menu_option.dart';

/// General actions available in the calculator menus.
enum GeneralAction { actualizar, avanzadas, personalizados }

/// Menu options for [GeneralAction].
const generalMenuOptions = <MenuOption<GeneralAction>>[
  MenuOption(
    value: GeneralAction.actualizar,
    label: 'Actualizar datos',
    icon: Icons.sync,
  ),
  MenuOption(
    value: GeneralAction.avanzadas,
    label: 'Opciones avanzadas',
    icon: Icons.tune,
  ),
  MenuOption(
    value: GeneralAction.personalizados,
    label: 'Valores personalizados',
    icon: Icons.edit,
  ),
];
