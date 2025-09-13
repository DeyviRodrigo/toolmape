# Documentación del proyecto

Este documento resume la estructura de ToolMAPE conforme a los principios de Clean Architecture, Domain-Driven Design (DDD), el patrón MVVM con Riverpod y Atomic Design.

## Estructura de carpetas

```
lib/
  app/                # Punto de entrada, rutas y shell de la aplicación
  core_foundation/    # Configuraciones base y tema global
  features/
    general/          # Recursos compartidos y reutilizables
      data/
      domain/
      infrastructure/
      presentation/
        atoms/        # Ej. NumericField, MenuOption, LegendItem
        molecules/    # Ej. AppDrawerItem, ConfirmDialog, MenuPopupButton
        organisms/    # Ej. AppDrawer
        pages/        # Ej. SplashPage
        providers/    # Ej. UserPrefsNotifier
    calculator/       # Módulo calculadora de precios
      core/
      domain/
      infrastructure/
      presentation/
    calendar/         # Módulo calendario minero
      core/
      data/
      domain/
      presentation/
  theme/              # Temas y tokens de diseño
```

Cada módulo dentro de `features` contiene sus propias capas: **domain**, **data/infrastructure**, **presentation** y **usecases**, encapsulando la lógica específica del dominio.

## Componentes principales

### Widgets y vistas
- **CalculadoraPage** – interfaz para calcular el precio del oro.
- **CalendarioPage** – consulta y gestión del calendario minero.
- **SplashPage** – pantalla inicial de carga.
- **AppShell** – Scaffold base con AppBar y Drawer.
- **AppDrawer** – menú lateral de navegación.
- **LegendItem** – elemento de leyenda reutilizable.
- **NumericField** – campo de texto numérico.

### Controladores y notifiers
- **CalculadoraController** – lógica del cálculo y preferencias.
- **CalendarioController** – maneja el estado del calendario.
- **ParametrosNotifier** – valores recomendados para la calculadora.
- **UserPrefsNotifier** – persistencia de preferencias locales del usuario.

### Servicios y utilidades
- **CalculadoraFormulas** – operaciones para el cálculo de precios del oro.
- **CalendarioNotifications** – gestión de notificaciones locales.
- **Formatters** y **NumberParsing** – utilidades comunes para formato de datos.

