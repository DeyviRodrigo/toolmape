import 'package:flutter/material.dart';

import 'menu_option.dart';

/// General actions available in the calculator menus.
enum GeneralAction {
  actualizar,
  avanzadas,
  solicitarValorTiempoReal,
  solicitarAnalisis,
}

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
    value: GeneralAction.solicitarValorTiempoReal,
    label: 'Solicitar valor en tiempo real',
    icon: Icons.flash_on,
  ),
  MenuOption(
    value: GeneralAction.solicitarAnalisis,
    label: 'Solicitar análisis para la compra-venta de oro',
    icon: Icons.analytics,
  ),
];
