# 🏗️ Plan De Implementación
La aplicación **Antigravity** se estructura bajo **Clean Architecture + Feature-First**, garantizando separación estricta de responsabilidades, testabilidad y escalabilidad empresarial. El flujo de datos sigue la dirección: `UI → Presentation (Provider) → Domain (UseCases) → Data (Repositories/DataSources) → External (Dio/Firestore/Local)`.

- **Gestión de Estado:** `Provider` (vía `ChangeNotifierProvider`/`StateProvider` según necesidad) para inyección de dependencias y propagación reactiva de estado. Se evita Riverpod conforme a la instrucción final, manteniendo compatibilidad total con el ecosistema Flutter estable.
- **Navegación:** `go_router` para enrutamiento declarativo, rutas anidadas, redirecciones protegidas por rol y soporte de deep linking.
- **Capa de Red:** `dio` con interceptores centralizados para autenticación (Bearer tokens), logging estructurado, manejo de tiempos de espera y cacheo HTTP.
- **Modelos Inmutables:** `freezed` + `json_serializable` garantizan type-safety, inmutabilidad, serialización/deserialización predecible y generación automática de `copyWith`, `toString`, y `==`.
- **Manejo de Errores:** Patrón `Result<Failure, Success>` (o `Either` conceptual) en UseCases. Las excepciones de red y dominio se mapean a clases `Failure` tipificadas (`NetworkFailure`, `ValidationFailure`, `ServerFailure`, `AuthFailure`) para manejo uniforme en UI.
- **Tema y Accesibilidad:** Material 3 con paleta exacta proporcionada. Sistema de contraste automático basado en cálculo de luminancia relativa WCAG AA, garantizando ratios ≥ 4.5:1 para texto normal y ≥ 3:1 para texto grande.
- **Optimización Multiplataforma:** Canvaskit forzado en Web para rendimiento gráfico estable, gestión explícita de escalado DPI en Windows, y safe areas adaptativos en Android/iOS mediante `MediaQuery` y `LayoutBuilder`.

---

# 📂 Árbol de Archigos

```
antigravity/
├── lib/
│   ├── core/
│   │   ├── constants/          # Environment, routes, api endpoints, app metadata
│   │   ├── errors/             # Failure, Result, ExceptionMapper, UseCaseError
│   │   ├── network/            # Dio client, interceptors, retry policy, cache config
│   │   ├── theme/              # AppTheme, color system, typography, WCAG AA contrast engine
│   │   ├── utils/              # Date/number formatters, validators, platform helpers, logger
│   │   └── widgets/            # App-level UI (buttons, inputs, dialogs, loading states, banners)
│   ├── features/
│   │   ├── category/           # data / domain / presentation
│   │   ├── supplier/           # data / domain / presentation
│   │   ├── product/            # data / domain / presentation
│   │   ├── client/             # data / domain / presentation
│   │   ├── employee/           # data / domain / presentation
│   │   ├── sale/               # data / domain / presentation
│   │   ├── sale_detail/        # data / domain / presentation
│   │   ├── purchase/           # data / domain / presentation
│   │   └── purchase_detail/    # data / domain / presentation
│   ├── app.dart                # MaterialApp.router, Provider scopes, theme injection
│   └── main.dart               # Entry point, platform init, error zone, Provider tree
├── test/                       # Espejo exacto de lib/ con unit, widget e integration tests
├── assets/                     # Fonts, icons, lottie, localization, mock data
└── pubspec.yaml
```

---

# 📄 Descripción Conceptual de Archivos Base (Sin Código)

### `lib/main.dart`
- Punto de entrada único. Configura `FlutterError.onError` y `runZonedGuarded` para captura global de excepciones no manejadas.
- Inicializa servicios críticos: `Dio`, `Logger`, `Provider` root, configuración de plataforma (CanvasKit en Web, escala de píxeles en Windows).
- Envuelve la aplicación en `MultiProvider` con alcance global para servicios singleton y estado de autenticación/sesión.
- Invoca `App()` tras resolver dependencias síncronas críticas.

### `lib/app.dart`
- Define `MaterialApp.router` con configuración de Material 3.
- Inyecta `AppTheme` generado dinámicamente.
- Configura `routerConfig` (go_router) con interceptores de navegación para guards de sesión y permisos por rol.
- Centraliza observables de `Provider` para logging de transiciones de estado y manejo de errores globales (`ErrorWidget.builder` personalizado).
- Aplica `LayoutBuilder` y `MediaQuery` para adaptación responsive y safe areas.

### `lib/core/theme/app_theme.dart`
- Define sistema de colores exacto: pastel base (`#A7C7E7`, `#F4A6C1`, `#C8A2C8`), acentos (`#6FA8DC`, `#4A90E2`, `#E87EA1`, `#D95C8A`, `#A87BBF`), neutros (`#FFFFFF` → `#333333`), estados (`#A8D5BA`, `#F28B82`, `#F7E6A1`).
- Implementa motor de contraste WCAG AA: calcula luminancia relativa por fórmula estándar, evalúa ratio entre foreground/background, y ajusta automáticamente tonos secundarios si no superan 4.5:1.
- Configura `ColorScheme.fromSeed` con overrides explícitos para mantener fidelidad a la paleta.
- Define escalas tipográficas responsive, tokens de espaciado (8px grid), y configuraciones de elevación/shape Material 3.

### `lib/core/router/app_router.dart`
- Declara rutas jerárquicas por feature usando `GoRoute` y `ShellRoute`.
- Implementa `redirect` function para validación de sesión, expiración de token y redirección a login o dashboard según rol (Cliente, Empleado, Admin).
- Configura transiciones personalizadas, deep links, y parámetros tipados.
- Separa rutas públicas, protegidas y de mantenimiento.

---

# 🧩 Template de Feature y Mapeo de Entidades

Cada feature sigue la estructura `data/`, `domain/`, `presentation/`. Las 9 entidades SQL se mapean así:

| Entidad SQL            | Feature Folder       | Domain Entity       | UseCase Ejemplo                  |
|------------------------|----------------------|---------------------|----------------------------------|
| `CATEGORIA`            | `features/category/` | `Category`          | `GetCategories`, `SyncCategory`  |
| `PROVEEDOR`            | `features/supplier/` | `Supplier`          | `CreateSupplier`, `ListSuppliers`|
| `PRODUCTO`             | `features/product/`  | `Product`           | `SearchProducts`, `UpdateStock`  |
| `CLIENTE`              | `features/client/`   | `Client`            | `RegisterClient`, `GetHistory`   |
| `EMPLEADO`             | `features/employee/` | `Employee`          | `AuthenticateEmployee`, `GetRole`|
| `VENTA`                | `features/sale/`     | `Sale`              | `CreateSale`, `GetSalesByDate`   |
| `DETALLE_VENTA`        | `features/sale_detail/` | `SaleDetail`   | `AddLineItem`, `RecalculateTotal`|
| `COMPRA`               | `features/purchase/` | `Purchase`          | `RegisterPurchase`, `AuditStock` |
| `DETALLE_COMPRA`       | `features/purchase_detail/` | `PurchaseDetail` | `LinkToSupplier`, `ValidateCost` |

**Estructura interna por feature:**
- `data/`: DTOs (`freezed`), `DataSource` (abstracto con implementaciones remote/local), `RepositoryImpl` (mapea DTO→Entity, maneja `Result`).
- `domain/`: Entity inmutable, `Repository` interface, `UseCase` classes (heredan de base genérica `ResultUseCase<Params, ReturnType>`).
- `presentation/`: `Provider`/`ChangeNotifier` (gestiona estado UI, llama UseCases, expone streams/notifiers), `View` (pantalla responsive), `Widgets` específicos del feature.

---

# ⚙️ Instrucciones `build_runner` y Ejecución Multiplataforma

### Generación de Código
1. Asegurar que todas las clases anotadas con `@freezed`, `@JsonSerializable`, y `@provider` estén definidas.
2. Ejecutar en terminal: `flutter pub run build_runner build --delete-conflicting-outputs`
3. Para modo observador (desarrollo): `flutter pub run build_runner watch --delete-conflicting-outputs`
4. Verificar generación en archivos `.g.dart`, `.freezed.dart`, y `*.g.dart` para Provider annotations si se usa extensión codegen-compatible.

### Ejecución Multiplataforma
- **Web (CanvasKit):** `flutter run -d chrome --web-renderer canvaskit` (mejor rendimiento gráfico y consistencia visual).
- **Windows:** `flutter run -d windows` → Validar `windows/runner/win32_window.cpp` para DPI awareness (`PROCESS_PER_MONITOR_DPI_AWARE`).
- **Android:** `flutter run -d <device_id>` → Habilitar `android/app/src/main/AndroidManifest.xml` con `hardwareAccelerated="true"`.
- **iOS:** `flutter run -d <simulator/device>` → Configurar `ios/Runner/Info.plist` con permisos de red y safe area flags.
- **Build Release:** `flutter build apk --release`, `flutter build ipa`, `flutter build web --release`, `flutter build windows --release`.

---

# ♿ Notas de Accesibilidad, Rendimiento y Escalabilidad

### Accesibilidad (WCAG AA)
- Cálculo automático de luminancia relativa: `L = 0.2126 * R' + 0.7152 * G' + 0.0722 * B'` (con gamma correction sRGB).
- Ratio de contraste: `(L1 + 0.05) / (L2 + 0.05)`. Si `< 4.5`, el sistema ajusta el foreground al siguiente tono oscuro/claro válido.
- Semántica expuesta: `Semantics` widgets en inputs, botones y listas. Soporte para TalkBack/VoiceOver y alto contraste del sistema.

### Rendimiento
- **Red:** `dio` con cacheo de respuestas GET, compresión gzip, reintentos exponenciales y timeout por request.
- **UI:** `ListView.builder`/`GridView.builder` para paginación, `const` constructors en widgets estáticos, `RepaintBoundary` en secciones complejas.
- **Web:** Lazy loading de rutas, asset defer, minimización de main.dart.js, CanvasKit para estabilidad de shaders.
- **Memoria:** Disposición explícita de controllers/providers no usados, `ImageCache` configurado con límites por plataforma.

### Escalabilidad
- Arquitectura desacoplada: nuevos features se añaden como módulos independientes sin modificar core.
- Feature flags mediante `shared_preferences` o backend para habilitar/deshabilitar funcionalidades sin redeploy.
- Repositorios con estrategia de cache híbrida (memory + local DB) para operación offline parcial.
- Logging estructurado con niveles (`debug`, `info`, `warn`, `error`), contexto de traza y sanitización de PII.

---

# ✅ Checklist de Próximos Pasos

- [ ] Configurar pipelines CI/CD (GitHub Actions / Codemagic) con jobs por plataforma.
- [ ] Implementar testing pyramid: Unit (domain/data), Widget (presentation), Integration (flujos críticos).
- [ ] Firmas y keystores: generar `upload-keystore.jks`, configurar `key.properties`, preparar provisioning profiles iOS.
- [ ] Integrar Crashlytics/Sentry para monitoreo de errores en producción.
- [ ] Validar reglas de Firestore/Backend para acceso por rol y auditoría de ventas/compras.
- [ ] Ejecutar auditoría de accesibilidad con `flutter analyze --no-pub` y `flutter test --platform chrome`.
- [ ] Preparar metadatos de tienda: screenshots responsive, descripciones, políticas de privacidad, categorías.
- [ ] Ejecutar pruebas de carga con usuarios simultáneos y sincronización de inventario en tiempo real.
- [ ] Documentar API contracts y flujos de sincronización offline/online.

---

# 📦 Dependencias (Stack de 25 Paquetes)

| Tipo       | Paquete                                      | Propósito                                           |
|------------|----------------------------------------------|-----------------------------------------------------|
| Core       | `flutter` / `dart`                           | SDK base                                            |
| State      | `provider`                                   | Gestión reactiva de estado e inyección              |
| Routing    | `go_router`                                  | Navegación declarativa y guards                     |
| Network    | `dio`                                        | Cliente HTTP avanzado                               |
| Serial     | `freezed` / `json_annotation` / `json_serializable` | Modelos inmutables y parsing seguro          |
| Utils      | `equatable` / `collection` / `intl`          | Comparación, colecciones, formato fecha/moneda      |
| UI         | `flutter_screenutil` / `cached_network_image`| Responsive scaling y gestión de imágenes            |
| Theme      | `google_fonts` / `flutter_svg`               | Tipografía consistente e iconografía vectorial      |
| Storage    | `shared_preferences` / `hive` / `path_provider` | Preferencias y cache local                    |
| Security   | `flutter_secure_storage`                     | Almacenamiento cifrado de tokens/credenciales       |
| Testing    | `mocktail` / `mockito`                       | Mocks para domain/data layers                       |
| Dev/Build  | `build_runner` / `analyzer` / `flutter_lints`| Generación de código y análisis estático            |
| Observ     | `logger` / `sentry_flutter` / `firebase_crashlytics` | Logging estructurado y crash reporting        |
| Multiplat  | `window_manager` / `url_launcher` / `device_info_plus` | Control de ventana, deep links, info de HW   |

> **Nota:** Todas las versiones deben fijarse a la última estable compatible con Flutter 3.x+ y Dart 3.x+. Se recomienda utilizar `flutter pub deps` y `flutter pub outdated` para auditoría periódica de vulnerabilidades y compatibilidad.

Aquí tienes el bloque de dependencias listo para insertar en `pubspec.yaml`, estructurado por capas, con versiones compatibles con **Dart 3.x / Flutter 3.24+**, comentarios en español y estricto cumplimiento de null-safety/type-safety.

```yaml
dependencies:
  flutter:
    sdk: flutter

  # 🔄 Gestión de Estado
  provider: ^6.1.2                      # Inyección y propagación reactiva (ChangeNotifier, Stream, Future)

  # 🧭 Navegación Declarativa
  go_router: ^14.6.2                    # Enrutamiento con guards, deep links y transiciones configurables

  # 🌐 Red & HTTP
  dio: ^5.7.0                           # Cliente HTTP con interceptores, retries y timeout configurables

  # 📦 Serialización & Modelos Inmutables
  freezed_annotation: ^2.4.4            # Anotaciones para @freezed
  json_annotation: ^4.9.0               # Anotaciones para @JsonSerializable

  # 🎨 UI, Tema & Responsive
  flutter_screenutil: ^5.9.3            # Escalado de UI basado en DPI y densidad de pantalla
  cached_network_image: ^3.4.1          # Cache de imágenes con soporte de placeholder y error widget
  google_fonts: ^6.2.1                  # Tipografía consistente y cargada desde assets/red
  flutter_svg: ^2.0.16                  # Renderizado de iconos y vectores SVG optimizado

  # 💾 Almacenamiento & Seguridad
  shared_preferences: ^2.3.4            # Preferencias ligeras (tema, idioma, feature flags)
  flutter_secure_storage: ^9.2.4        # Almacenamiento cifrado de tokens/credenciales por plataforma
  hive: ^2.2.3                          # Base de datos local ultrarrápida y type-safe
  hive_flutter: ^1.1.0                  # Integración de Hive con Flutter widgets y streams
  path_provider: ^2.1.4                 # Rutas de almacenamiento nativo por SO

  # 🛠️ Utilidades & Formato
  equatable: ^2.0.7                     # Comparación inmutable sin boilerplate
  intl: ^0.20.2                         # Formateo de fechas, números y monedas (locale-aware)
  logger: ^2.5.0                        # Logging estructurado con niveles, filtros y contexto
  collection: ^1.19.0                   # Extensiones de listas/mapas (groupBy, deep equality, etc.)
  uuid: ^4.5.1                          # Generación de identificadores únicos RFC4122

  # 🖥️ Observabilidad & Multiplataforma
  sentry_flutter: ^8.11.2               # Crash reporting y tracing en producción
  window_manager: ^0.4.3                # Control nativo de ventana en Windows/Linux/macOS
  url_launcher: ^6.3.1                  # Apertura segura de enlaces externos
  device_info_plus: ^11.2.1             # Información de hardware/SO para ajustes por plataforma

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0                 # Reglas de linting empresariales actualizadas
  build_runner: ^2.4.14                 # Motor de generación de código
  freezed: ^2.5.8                       # Generador de @freezed (copyWith, ==, toString, JSON)
  json_serializable: ^6.9.3             # Generador de @JsonSerializable (fromJson/toJson)
  mocktail: ^1.0.4                      # Mocks type-safe para testing unitario y de integración
```

---

### 🔍 Notas Críticas de Integración

1. **Validación de Versiones:**  
   Ejecuta `flutter pub get` seguido de `flutter pub outdated`. Si alguna dependencia muestra `resolvable` o `discontinued`, actualiza con `flutter pub upgrade <paquete>` hasta la última versión estable compatible con Flutter 3.x.

2. **Compatibilidad Dart 3.x:**  
   Todas estas versiones aprovechan `sealed classes`, `pattern matching` y `record types`. Asegúrate de que `pubspec.yaml` incluya:
   ```yaml
   environment:
     sdk: ">=3.5.0 <4.0.0"
   ```

3. **Ejecución de `build_runner`:**  
   - Primera generación:  
     `dart run build_runner build --delete-conflicting-outputs`
   - Modo desarrollo (watch):  
     `dart run build_runner watch --delete-conflicting-outputs`
   - Los archivos `.g.dart`, `.freezed.dart` y `*.gr.dart` se generarán automáticamente junto a sus fuentes.

4. **Seguridad & Producción:**  
   - `flutter_secure_storage` requiere configuración nativa en `AndroidManifest.xml`, `Info.plist` y `windows/CMakeLists.txt` para permisos de keychain/keystore.
   - `sentry_flutter` debe inicializarse en `main.dart` con `SentryFlutter.init()` y DSN inyectado por entorno.

5. **Cero Dependencias Obsoletas:**  
   Se han excluido paquetes como `http` (reemplazado por `dio`), `get` (reemplazado por `provider` + `go_router`), y `provider`-alternativas no oficiales para mantener un stack auditado, mantenible y compatible con políticas empresariales de Flutter.

¿Requieres que te entregue la sección `pubspec.yaml` completa con `flutter` assets, `resolutions` para conflictos conocidos, o la estructura de `analysis_options.yaml` con `flutter_lints` empresariales?
---

Este plan garantiza una base empresarial, segura, accesible y lista para escalar. La estructura respeta estrictamente **Clean Architecture + Feature-First**, utiliza **Provider** como gestor central, integra las **9 entidades** de negocio, aplica la **paleta exacta** con validación WCAG AA, y optimiza el despliegue en **Android, iOS, Web y Windows**. ¿Requiere ajuste en la distribución de features, políticas de cache offline, o definición de roles/permisos antes de iniciar la generación de artefactos?

## PROMPT
Actúa como Arquitecto Senior de Flutter (Dart 3.x/Flutter 3.x+) y genera un plan de implementación técnico detallado junto con el código base inicial para el proyecto "Antigravity", orientado a producción y compatible con Android, iOS, Web y Windows, aplicando Clean Architecture + Feature-First, Riverpod 2.x con codegen, go_router, dio, freezed + json_serializable, y una estructura estricta con `lib/core/` (constants, errors, network, theme, utils, widgets), `lib/features/` (data/domain/presentation) y `test/` en espejo; integra la paleta exacta proporcionada (pastel base: `#A7C7E7`, `#F4A6C1`, `#C8A2C8`; acentos: `#6FA8DC`, `#4A90E2`, `#E87EA1`, `#D95C8A`, `#A87BBF`; neutros: `#FFFFFF` a `#333333`; estados: `#A8D5BA`, `#F28B82`, `#F7E6A1`) garantizando cumplimiento WCAG AA mediante cálculo automático de luminancia para contrastes, Material 3 y layouts responsive con `LayoutBuilder`/`MediaQuery`; utiliza las 25 dependencias especificadas, implementa manejo centralizado de errores (patrón `Failure`/`Result` o `Either`), logging estructurado e interceptores de red, aplica optimizaciones por plataforma (Canvaskit para web, gestión de DPI en Windows, safe areas en móviles/iOS) y entrega la salida estructurada que incluya: resumen arquitectónico, árbol de archivos, código listo para producción de `main.dart`, `app.dart`, `core/theme/app_theme.dart`, `core/router/app_router.dart` y un feature template completo, instrucciones precisas para `build_runner` y ejecución multiplataforma, notas de accesibilidad/rendimiento/escalabilidad, y checklist de próximos pasos (CI/CD, testing, signing), manteniendo código 100% null-safe/type-safe, nomenclatura en inglés, comentarios en español cuando sea útil, cero dependencias obsoletas, imports completos y adherencia estricta a estándares de mantenimiento empresarial. Ten en cuenta las entidades que ya tenemos, por favor. Utiliza Provider.
