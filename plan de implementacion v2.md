Aquí tienes un **plan de implementación profesional y estructurado** para **Antigravity** en Flutter, listo para escalar a Android, iOS, Web y Windows. Incluye un prompt reutilizable de alta calidad, arquitectura recomendada, estructura de carpetas, sistema de temas con tu paleta, y un roadmap técnico por fases.

---
## 📝 Prompt Profesional Reutilizable (para generar código futuro)
```text
Actúa como un Arquitecto de Software Senior especializado en Flutter (multiplataforma). 
Proyecto: Antigravity
Stack: Flutter 3.x+, Dart 3.x, go_router, Riverpod 2.x, dio, flutter_lints
Arquitectura: Clean Architecture + Feature-First
Paleta: [pegar tu paleta exacta o referenciar "AppTheme.pastelTokens"]
Requisitos:
1. Código type-safe, null-safe, con comentarios mínimos pero claros.
2. Separación estricta: presentation / domain / data.
3. Estado manejado con Riverpod (notifier/family si aplica).
4. UI responsive y accesible (contraste WCAG AA mínimo).
5. Manejo de errores centralizado (Either/Result pattern o Excepciones tipadas).
6. Widgets reutilizables en core/widgets/.
7. Incluir pruebas unitarias y de widget donde aplique.
8. No usar paquetes obsoletos. Priorizar estabilidad y mantenimiento.
Salida esperada: 
- Explicación breve de decisiones arquitectónicas
- Estructura de archivos impactados
- Código completo listo para copiar/pegar
- Notas de integración multiplataforma (si aplica)
```

---
## 🗺️ Plan de Implementación Estructurado

| Fase | Objetivo | Entregables Clave | Duración Estimada |
|------|----------|-------------------|-------------------|
| **1. Setup & Base** | Inicializar proyecto, lints, CI básico | `pubspec.yaml`, `analysis_options.yaml`, estructura base, `main.dart` | 1-2 días |
| **2. Core & Theme** | Sistema de diseño, routing, utilidades | `AppTheme`, `AppColors`, `go_router`, `AppConstants`, `core/widgets/` | 2-3 días |
| **3. Data & Domain** | Capa de datos, repositorios, entidades | Interfaces, casos de uso, mocks, `dio` config, error handling | 3-4 días |
| **4. Features** | Desarrollo por módulos (ej: auth, home, settings) | Pantallas, viewmodels, states, navegación, responsive layout | 5-10 días/feature |
| **5. Multi-Platform** | Ajustes OS-específicos | `window_manager`, web optimizations, safe areas, platform channels | 3 días |
| **6. Testing & QA** | Validación automatizada | Unit, widget, integration tests, lighthouse/web, perf profiling | 3-4 días |
| **7. CI/CD & Deploy** | Pipeline y distribución | GitHub Actions, fastlane, web build, signing, release notes | 2-3 días |

> ✅ **Nota:** El plan es iterativo. Cada feature sigue el ciclo: `Domain → Data → Presentation → Tests → Review`.

---
## 📁 Estructura de Carpetas (Feature-First + Clean Architecture)

```
lib/
├── core/
│   ├── constants/          # AppConstants, Routes, Strings
│   ├── errors/             # Failure, AppException, Result<Either>
│   ├── network/            # DioClient, interceptors, retry logic
│   ├── theme/              # AppTheme, color tokens, typography, spacing
│   ├── utils/              # Validators, formatters, date helpers, logger
│   └── widgets/            # Reusable: AppButton, AppCard, LoadingOverlay, ErrorBanner
├── features/
│   └── auth/               # Ejemplo de feature
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── providers/  # Riverpod notifiers
│           ├── screens/
│           └── widgets/
├── main.dart               # Entry point, app init, DI boot
└── app.dart                # MaterialApp/WidgetsApp wrapper
```

> 📦 **Test Mirror:** `test/` replica exactamente la estructura de `lib/`.

---
## 🎨 Sistema de Temas con tu Paleta

### 1. Mapeo Semántico (Recomendado para escalabilidad)
```dart
abstract class AppColors {
  // Base Pastel
  static const blueLight   = Color(0xFFA7C7E7);
  static const pinkSoft    = Color(0xFFF4A6C1);
  static const purpleLav   = Color(0xFFC8A2C8);

  // Secundarios / Acentos
  static const blueMid     = Color(0xFF6FA8DC);
  static const blueIntense = Color(0xFF4A90E2);
  static const pinkIntense = Color(0xFFE87EA1);
  static const pinkStrong  = Color(0xFFD95C8A);
  static const purpleMid   = Color(0xFFA87BBF);

  // Neutros
  static const white       = Color(0xFFFFFFFF);
  static const grayBg      = Color(0xFFF5F5F5);
  static const grayLight   = Color(0xFFEAEAEA);
  static const grayMid     = Color(0xFFAAAAAA);
  static const grayText    = Color(0xFF555555);
  static const grayDark    = Color(0xFF333333);

  // Estados
  static const success     = Color(0xFFA8D5BA);
  static const error       = Color(0xFFF28B82);
  static const warning     = Color(0xFFF7E6A1);
}
```

### 2. Integración en `ThemeData`
```dart
final lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: AppColors.blueIntense,
    secondary: AppColors.pinkStrong,
    surface: AppColors.white,
    background: AppColors.grayBg,
    error: AppColors.error,
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    onSurface: AppColors.grayDark,
    onError: AppColors.grayDark,
  ),
  scaffoldBackgroundColor: AppColors.grayBg,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.blueLight,
    foregroundColor: AppColors.grayDark,
    elevation: 0,
  ),
  useMaterial3: true,
  extensions: const [AppPastelExtension()], // Para tokens custom
);
```

> ⚠️ **Accesibilidad:** Los pasteles puros no pasan WCAG AA para texto. Usa `grayDark` o `blueIntense` sobre fondos claros, y genera `onX` automáticamente con `Color.computeLuminance()`.

---
## ⚙️ Stack Técnico Recomendado (2024-2026)

| Capa | Tecnología | Justificación |
|------|------------|---------------|
| **State** | `riverpod` + `riverpod_generator` | Type-safe, testable, sin boilerplate excesivo |
| **Routing** | `go_router` | Declarativo, deep-linking, multi-plataforma estable |
| **HTTP** | `dio` + `retrofit` o `chopper` | Interceptores, logging, cancelación nativa |
| **Storage** | `isar` o `hive` | Rápido, cross-platform, sin SQLite nativo pesado |
| **UI Base** | Material 3 + `responsive_builder` / `flexible_layout` | Adaptación fluida a móvil/desktop/web |
| **Testing** | `mocktail`, `riverpod_test`, `integration_test` | Cobertura realista y mantenible |
| **CI/CD** | GitHub Actions + `fastlane` + `shorebird` (opcional) | Builds automáticos, OTA updates, signing seguro |

---
## 🌍 Consideraciones Multiplataforma

| Plataforma | Ajustes Clave |
|------------|---------------|
| **Web** | `--web-renderer canvaskit` para consistencia, optimizar assets, evitar `dart:io`, usar `url_launcher` para links |
| **Windows** | `window_manager` para bordes personalizados, ajustar DPI, habilitar `flutter run -d windows` |
| **iOS** | Safe areas, `flutter_native_splash`, signing certificates, `Info.plist` permissions |
| **Android** | `targetSdk 34+`, `android:exported`, permisos runtime, App Bundle (`--release`) |
| **General** | `LayoutBuilder` + `MediaQuery` para responsive, evitar `hardcoded sizes`, usar `kIsWeb` solo cuando sea estrictamente necesario |

---
## ✅ Checklist de Calidad Pre-Release

- [ ] `flutter analyze` sin warnings (excepto `prefer_const_constructors` controlado)
- [ ] `dart format lib/ test/` aplicado
- [ ] `coverage >= 70%` en capa domain/data
- [ ] Tema light/dark validado con contraste WCAG AA
- [ ] Navegación probada en hotlink/deep link
- [ ] Assets optimizados (`flutter pub run flutter_native_splash:create`)
- [ ] `pubspec.yaml` con versiones fijas (`^` solo si es seguro)
- [ ] Pipeline CI falla en `flutter test` o `analyze`

---
## 🚀 Próximos Pasos Sugeridos

1. Ejecuta: `flutter create antigravity --org com.tuempresa`
2. Aplica `flutter_lints`, `analysis_options.yaml` y estructura de carpetas
3. Implementa `AppTheme` + `go_router` + `riverpod` en `lib/core/`
4. Desarrolla 1 feature completa (ej: `onboarding` o `dashboard`) como template
5. Configura GitHub Actions con `flutter test` + `build web/windows`

¿Quieres que genere el **código base completo** de `main.dart`, `app.dart`, `AppTheme`, `go_router` setup y un **feature template** listo para escalar? Indica qué módulo priorizar (ej: Auth, Dashboard, Settings) y te entrego el código listo para producción con tu paleta integrada.
