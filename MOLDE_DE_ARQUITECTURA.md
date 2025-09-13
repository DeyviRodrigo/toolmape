# MOLDE_DE_ARQUITECTURA.md — Canon del proyecto
SPEC_VERSION: 1.0

## Propósito
Establecer un molde único (Clean Architecture + DDD + MVVM con Riverpod + Atomic Design) para **organizar código sin alterar cómo se VE ni cómo FUNCIONA** la app.

## Principios (obligatorios)
- Dominio = **puro Dart** (sin Flutter/HTTP/plugins).
- Flujo MVVM: **Page → ViewModel → UseCase → Repository(iface) → RepositoryImpl → DataSource**.
- **DTO ≠ Entidad**: JSON solo en `data/`; reglas en `domain/`.
- UI con Atomic Design: `atoms → molecules → organisms → pages`. Sin lógica de negocio en UI.
- Imports permitidos:
    - `presentation` → puede importar `domain` y `viewmodels`; **no** `infrastructure`.
    - `domain` → no importa Flutter/plugins/data/infra.
    - `infrastructure` → puede importar `data` y `domain`; **no** widgets.
    - `data` → no importa widgets/plugins.
- Nombres: `XRepository` / `XRepositoryImpl` / `XDto` / `XMapper` / `XViewModel` / `XState`; use cases con verbo (`GetX`, `CreateY`, `CalculateZ`).
- Refactors con compatibilidad: si renombras o mueves algo, agrega **typedef/re-export** temporal para no romper.

## Árbol base
lib/
app/{bootstrap,router,shell,di}
core/{config,errors,utils,services,theme/{tokens,themes,extensions}}
features/
<feature_name>/
domain/{entities,value_objects,repositories,usecases}
data/{dtos,mappers}
infrastructure/{datasources,repositories,adapters|services}
presentation/{atoms,molecules,organisms,pages,viewmodels,navigation?}
assets/
test/ # espeja lib/
docs/

markdown
Copiar código

## Molde por feature (repetible)
Ruta: `lib/features/{{feature_name}}/`

- `domain/`
    - `entities/{{Entity}}.dart` (inmutable, sin Flutter)
    - `value_objects/` (si aplica)
    - `repositories/{{feature}}_repository.dart` (contrato)
    - `usecases/{{UseCase}}.dart` (orquesta reglas y llama repo)
- `data/`
    - `dtos/{{entity_snake}}_dto.dart` (`fromJson/toJson`)
    - `mappers/{{entity_snake}}_mapper.dart` (DTO↔Entidad)
- `infrastructure/`
    - `datasources/{{feature}}_remote_datasource.dart` (o local)
    - `repositories/{{feature}}_repository_impl.dart` (usa datasource + mapper)
    - `adapters/|services/` (clientes HTTP, notificaciones, etc.)
- `presentation/`
    - `atoms/`, `molecules/`, `organisms/`, `pages/{{feature}}_page.dart`
    - `viewmodels/{{feature}}_view_model.dart` (`{{feature}}_state.dart` opcional)
    - `navigation/` (rutas locales, si aplica)

**Prohibido:** UI llamando HTTP/DB/plugins; mappers en infraestructura; Flutter/HTTP en dominio.

## Reglas de cambio seguro (no romper UI/función)
- No modificar textos, colores, paddings o rutas visibles.
- No cambiar resultados numéricos ni formatos visibles.
- Cualquier renombre: proveer `typedef` o re-export temporal.
- Actualiza imports a `package:` (evitar relativos frágiles).

## Checklist de cumplimiento (previo a merge)
1) `domain` libre de Flutter/HTTP/plugins.
2) DTOs y mappers están en `data/`.
3) `presentation` no importa `infrastructure`.
4) Flujo MVVM intacto (Page→VM→UC→Repo→DS).
5) UI y comportamiento **idénticos**.
6) `test/` refleja `lib/` y hay ≥1 test por capa.
7) Imports `package:` consistentes.

## Contrato para asistentes (Codex/LLMs)
Al iniciar cualquier tarea:
1) **Leer este archivo** y mostrar `SPEC_VERSION` en tu salida.
2) Si alguna instrucción externa contradice este molde, **gana este molde**.
3) Entregar siempre:
    - **Plan + lista de archivos a tocar** (solo los necesarios).
    - **Cambios propuestos** (diffs o snippets) cumpliendo el checklist.
    - **Informe de cumplimiento**: marcar cada punto del checklist.
4) **Nunca** cambiar UI ni comportamiento existente. Si es inevitable, **detenerse** y pedir confirmación explícita.

## Apéndice (nomenclatura rápida)
- Entidad: `GoldPrice`, VO: `DateRange`
- Repo: `PriceRepository` / `PriceRepositoryImpl`
- DTO/Mapper: `GoldPriceDto` / `GoldPriceMapper`
- UseCase: `CalculateGoldPrice`
- VM/State: `CalculatorViewModel` / `CalculatorState`