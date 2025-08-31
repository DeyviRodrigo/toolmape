# Documentación de bloques

Este documento resume los principales bloques del código y su propósito.

## Widgets
- **ScreenCalculadora**: interfaz principal para calcular el precio del oro.
- **AppShell**: envoltorio con `AppBar` y `Drawer`.
- **AppDrawer**: menú lateral de navegación.
- **CalendarioMineroScreen**: pantalla para consultar el calendario.
- **CampoNumerico**: campo de texto para ingresar números.
- **_LegendItem**: elemento de leyenda para el calendario.

## Controladores y Notifiers
- **CalculadoraController**: gestiona la lógica de cálculo y preferencias.
- **ParametrosNotifier**: administra valores recomendados para el cálculo.
- **UserPrefsNotifier**: maneja preferencias persistentes del usuario.
- **MisEventosRepository**: operaciones sobre eventos personales.
- **CalendarioRepository**: acceso a eventos generales del calendario.

## Servicios y Utilidades
- **CalculadoraService**: fórmulas para el precio del oro.
- **CalendarioNotifications**: gestión de notificaciones locales.
- **choiceDialog**: cuadro de diálogo con opciones.
- **soles**: formatea números a moneda peruana.


