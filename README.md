# toolmape

ToolMAPE es tu app aliada en el día a día minero. Calcula precios de oro y minerales, accede a herramientas gratuitas, infórmate con resúmenes y blogs actualizados, y conecta con consultores expertos para impulsar tu actividad minera. Todo desde una sola plataforma, diseñada para el pequeño productor minero.

## Arquitectura y lineamientos

El proyecto adopta Clean Architecture, Domain-Driven Design, el patrón MVVM con Riverpod y Atomic Design. La estructura principal se organiza en módulos dentro de `lib/features`:

- `features/general` contiene recursos reutilizables. Sus subcarpetas `presentation/atoms`, `molecules`, `organisms`, `pages` y `providers` agrupan componentes según Atomic Design.
- Cada módulo funcional (por ejemplo `calculator` o `calendar`) incluye sus capas `domain`, `data`/`infrastructure`, `presentation` y `usecases`.
- Las vistas deben limitarse a la interfaz; la lógica pertenece a controladores, casos de uso o servicios.
- Cuando se creen nuevas piezas con inteligencia artificial, respete esta estructura de carpetas y reutilice los átomos y moléculas existentes.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
