import 'package:flutter/material.dart';

import 'menu_option.dart';

/// Acciones disponibles para el precio del oro en los menús de la calculadora.
enum PrecioOroAction { actualizar, avanzadas, tiempoReal, analisis }

/// Opciones de menú para [PrecioOroAction].
const precioOroMenuOptions = <MenuOption<PrecioOroAction>>[
  MenuOption(
    value: PrecioOroAction.actualizar,
    label: 'Actualizar datos',
    icon: Icons.sync,
  ),
  MenuOption(
    value: PrecioOroAction.avanzadas,
    label: 'Opciones avanzadas',
    icon: Icons.tune,
  ),
  MenuOption(
    value: PrecioOroAction.tiempoReal,
    label: 'Solicitar valor en tiempo real',
    icon: Icons.bolt,
  ),
  MenuOption(
    value: PrecioOroAction.analisis,
    label: 'Solicitar análisis para la compra-venta de oro',
    icon: Icons.analytics,
  ),
];

/// Acciones disponibles para el tipo de cambio en los menús de la calculadora.
enum TipoCambioAction { actualizar, avanzadas }

/// Opciones de menú para [TipoCambioAction].
const tipoCambioMenuOptions = <MenuOption<TipoCambioAction>>[
  MenuOption(
    value: TipoCambioAction.actualizar,
    label: 'Actualizar datos',
    icon: Icons.sync,
  ),
  MenuOption(
    value: TipoCambioAction.avanzadas,
    label: 'Opciones avanzadas',
    icon: Icons.tune,
  ),
];
