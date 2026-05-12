# 📋 Plan de Implementación: Aplicación "Papelería Cometa"

> **Nota preliminar:** "Antigravity" no es un IDE estándar para desarrollo Flutter. Se recomienda utilizar **VS Code** (con extensiones oficiales de Flutter/Dart) o **Android Studio**. Este plan está optimizado para VS Code.

---

## 🗂️ Estructura General del Proyecto
```
papeleria_cometa/
├── lib/
│   ├── core/          # Constantes, temas, utilidades, errores
│   ├── data/          # Modelos, repositorios, servicios Firebase
│   ├── presentation/  # Pantallas, widgets reutilizables, navegación
│   └── main.dart
├── assets/            # Imágenes, iconos, fuentes, mockups
└── pubspec.yaml
```

---

## 📅 Fases de Desarrollo (Paso a Paso)

### 🔹 Fase 1: Preparación del Entorno y Configuración Inicial
1. Instalar Flutter SDK y Dart.
2. Configurar VS Code con las extensiones: `Flutter`, `Dart`, `Pubspec Assist`, `Error Lens`.
3. Crear proyecto: `flutter create papeleria_cometa`
4. Inicializar repositorio Git y configurar `.gitignore` (incluir credenciales, build/, `.dart_tool/`).
5. Configurar variables de entorno para diferenciar `dev` y `prod`.

### 🔹 Fase 2: Integración de Firebase y Configuración de Backend
1. Crear proyecto en Firebase Console.
2. Registrar aplicaciones Android e iOS (descargar `google-services.json` y `GoogleService-Info.plist`).
3. Habilitar **Authentication** → método `Email/Password`.
4. Habilitar **Cloud Firestore** en modo `test` (luego se ajustarán reglas de seguridad).
5. Definir estructura de colecciones Firestore:
   - `users` → `{ uid, email, role, displayName, createdAt }`
   - `products` → `{ id, name, category, price, stock, image, description, isActive }`
   - `categories` → `{ id, name, icon }`
   - `orders` → `{ id, userId, items, total, status, createdAt }`
6. Configurar **Security Rules** en Firestore para restringir acceso según rol (`admin` vs `cliente`).

### 🔹 Fase 3: Arquitectura y Gestión de Estado
1. Adoptar patrón **Feature-First** o **Clean Architecture** simplificada.
2. Implementar `Provider` como gestor de estado principal:
   - `AuthProvider` → sesión, perfil, roles.
   - `ProductProvider` → catálogo, filtros, búsqueda.
   - `CartProvider` → carrito, totales, checkout.
3. Crear capa de servicios: `AuthService`, `FirestoreService`, `StorageService` (si se requieren imágenes).
4. Configurar enrutamiento protegido (`GuardedRoute`) para pantallas que requieren autenticación o rol específico.

### 🔹 Fase 4: Diseño UI/UX y Sistema de Componentes
1. Definir **Design System**:
   - Paleta de colores (primario, secundario, acento, fondos, textos).
   - Tipografía escalable (títulos, cuerpo, etiquetas).
   - Espaciado consistente (8px grid system).
   - Modo claro/oscuro.
2. Crear librería de widgets reutilizables:
   - `CustomButton`, `CustomTextField`, `ProductCard`, `CategoryChip`, `LoadingOverlay`, `ErrorBanner`.
3. Diseñar flujos de usuario (wireframes en Figma/Whimsical):
   - Login / Registro → Home/Catálogo → Detalle Producto → Carrito → Checkout → Perfil/Historial.
   - Panel Admin (opcional): CRUD productos, control de inventario, gestión de pedidos.
4. Asegurar diseño responsive para móviles y tablets.

### 🔹 Fase 5: Desarrollo de Funcionalidades Clave
1. **Autenticación**:
   - Validación de formularios (email formato, contraseña ≥6 caracteres).
   - Manejo de errores Firebase (usuario no existe, contraseña incorrecta, email ya registrado).
   - Persistencia de sesión y cierre seguro.
2. **Firestore Integración**:
   - Lectura paginada de productos (`limit`, `startAfterDocument`).
   - Búsqueda y filtrado por categoría/precio.
   - Operaciones CRUD para panel admin.
3. **Estado con Provider**:
   - Notificación de cambios en tiempo real (`StreamProvider` o `FutureProvider`).
   - Sincronización offline básica (cache local de catálogo).
4. **Navegación y Flujo de Negocio**:
   - Rutas protegidas por autenticación y rol.
   - Gestión de carrito (agregar, eliminar, actualizar cantidad).
   - Generación de orden en Firestore y limpieza de carrito post-compra.

### 🔹 Fase 6: Pruebas, Optimización y Despliegue
1. **Pruebas**:
   - Unit tests para lógica de negocio y repositorios.
   - Widget tests para pantallas críticas (login, carrito).
   - Pruebas en dispositivos reales y Firebase Test Lab.
2. **Optimización**:
   - Indexación de consultas en Firestore.
   - Compresión y caché de imágenes (`cached_network_image`).
   - Lazy loading y paginación eficiente.
3. **Seguridad**:
   - Validar entradas en cliente y servidor.
   - Revisar reglas de Firestore antes de producción.
   - Eliminar logs sensibles en build release.
4. **Despliegue**:
   - Generar APK/AppBundle y IPA.
   - Configurar metadatos para Google Play y App Store.
   - Implementar CI/CD básico (GitHub Actions / Codemagic) opcional.
   - Lanzamiento en fase beta → recolección de feedback → v1.0 estable.

---

## 📦 Dependencias Sugeridas (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  provider: ^latest
  flutter_screenutil: ^latest        # Responsive UI
  cached_network_image: ^latest      # Imágenes optimizadas
  google_fonts: ^latest              # Tipografía personalizada
  flutter_svg: ^latest               # Soporte SVG para iconos
  intl: ^latest                      # Formatos de fecha/moneda
  uuid: ^latest                      # IDs únicos locales
  shared_preferences: ^latest        # Preferencias ligeras (tema, idioma)
  flutter_secure_storage: ^latest    # Tokens o datos sensibles
  equatable: ^latest                 # Comparación de modelos limpios

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^latest
  build_runner: ^latest
  json_serializable: ^latest         # (Opcional) Serialización JSON
```

> ⚠️ **Nota:** Reemplaza `^latest` por la versión estable más reciente al momento de iniciar el proyecto. Usa `flutter pub outdated` para verificar actualizaciones seguras.

---

## ✅ Checklist de Validación Pre-Código
- [ ] Entorno Flutter + VS Code funcionando correctamente
- [ ] Proyecto Firebase creado con Auth y Firestore habilitados
- [ ] Estructura de carpetas y arquitectura definida
- [ ] Design System aprobado (colores, tipografía, componentes base)
- [ ] Flujo de navegación mapeado (wireframes o diagrama)
- [ ] Reglas de seguridad Firestore redactadas y revisadas
- [ ] `pubspec.yaml` con dependencias actualizadas y compatibles
- [ ] Estrategia de testing y despliegue definida

---

Una vez valides este plan y des el visto bueno, procederé a generar la **estructura base del proyecto, configuración de Firebase, implementación de Auth con Provider, y pantallas clave** con código listo para VS Code. ¿Deseas ajustar algún módulo, rol de usuario o funcionalidad antes de continuar?
