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

## Sugerencias de limpieza
- Revisar los manejadores `onTap` con `// TODO` en `lib/widgets/app_drawer.dart` (líneas 45, 50, 56 y 61) que no realizan acciones visibles.
- En `lib/features/calculadora/calculadora_screen.dart` existe un `// TODO` pendiente para el flujo de ayuda de ley (línea 240).
- `lib/features/calendario/calendario_screen.dart` contiene un `// TODO` sobre manejar overflow en una zona con scroll (línea 186).
- `lib/state/parametros.dart` incluye `// TODO` para cargar parámetros desde BD (línea 43).

Estas secciones pueden eliminarse o completarse si ya no son necesarias.
