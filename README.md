# 🎬 Movie Hub

App móvil (Android + iOS) hecha con **Flutter** para descubrir películas, ver
sus detalles y saber **dónde verlas** (Netflix, Disney+, HBO Max...). Incluye
tráilers de YouTube embebidos, búsqueda avanzada con filtros, lista de
favoritos guardada en el móvil y modo oscuro/claro con estética tipo Netflix.

Está construida con **Clean Architecture** y **Provider** para la gestión de
estado, usando la API de **TMDB (The Movie Database)**.

---

## ✅ Antes de empezar: qué necesitas en tu Mac

1. **Flutter instalado.** Si no lo tienes:
   👉 https://docs.flutter.dev/get-started/install/macos
   Comprueba que funciona abriendo la app **Terminal** y escribiendo:
   ```bash
   flutter --version
   ```
2. **Para probar en iPhone:** Xcode instalado (desde la App Store).
3. **Para probar en Android:** Android Studio instalado (para tener un
   emulador) o tu móvil Android con la "Depuración USB" activada.

---

## 🚀 Puesta en marcha (3 pasos)

### Paso 1 — Consigue tu clave gratuita de TMDB
1. Entra en https://www.themoviedb.org/ y crea una cuenta (gratis).
2. Ve a **tu avatar → Settings → API** y solicita una clave.
   Elige la opción **"Developer"** y rellena el formulario (uso personal).
3. Copia la **"API Key (v3 auth)"** (una cadena corta de letras y números).

### Paso 2 — Pega tu clave en el proyecto
Abre el archivo:
```
lib/core/constants/api_constants.dart
```
Y sustituye el texto `PON_AQUI_TU_API_KEY_DE_TMDB` por tu clave, entre las
comillas. Debe quedar algo así:
```dart
static const String apiKey = '8f2c1d3b4a5e6f7089abcd1234567890';
```
Guarda el archivo.

> 💡 Si te saltas este paso, la app arrancará y te mostrará una pantalla
> recordándote que falta la clave. No se rompe nada.

### Paso 3 — Deja el proyecto listo y ejecútalo
Abre la Terminal, entra en la carpeta del proyecto y ejecuta el script de
preparación (genera las carpetas de Android/iOS y descarga dependencias):
```bash
cd movie_hub
chmod +x setup.sh
./setup.sh
```

Después, conecta tu móvil (o abre un emulador) y arranca la app:
```bash
flutter run
```

¡Y ya está! 🎉

---

## 📱 Cómo probarla en tu móvil

- **Android:** conecta el móvil por USB con la "Depuración USB" activada
  (Ajustes → Opciones de desarrollador). Ejecuta `flutter run`.
- **iPhone:** conéctalo por USB, ábrelo en Xcode la primera vez para
  firmar la app con tu Apple ID, y luego `flutter run`.
- **Ver los dispositivos detectados:** `flutter devices`

---

## 🗂️ Estructura del proyecto (Clean Architecture)

```
lib/
├── core/            → Configuración común (tema, API key, cliente de red)
│   ├── constants/       · api_constants.dart  ← AQUÍ va tu clave de TMDB
│   ├── theme/           · colores, tipografía y temas claro/oscuro
│   ├── network/         · ApiClient (peticiones HTTP + errores)
│   └── utils/           · Failure (errores controlados)
│
├── data/            → De dónde salen los datos y cómo se transforman
│   ├── models/          · Modelos con parseo JSON (de/hacia la API y SQLite)
│   ├── datasources/     · MovieService (API TMDB) + Favoritos (SQLite)
│   └── repositories/    · Implementación del repositorio
│
├── domain/          → Reglas de negocio, independientes de todo lo demás
│   ├── entities/        · Objetos puros (Movie, MovieDetail, Genre...)
│   ├── repositories/    · Contrato (interfaz) del repositorio
│   └── usecases/        · Casos de uso (obtener tendencias, buscar, etc.)
│
└── presentation/    → Todo lo que ve el usuario
    ├── providers/       · Estado de cada pantalla (Provider)
    ├── screens/         · Inicio, Buscar, Detalle, Mi lista
    └── widgets/         · Piezas reutilizables (tarjetas, grid, reproductor...)
```

**¿Por qué esta estructura?** Cada capa solo depende de la de dentro
(presentation → domain ← data). Así puedes cambiar la API, la base de datos o
la interfaz sin romper el resto. Es la forma estándar de hacer apps escalables.

---

## 🧩 Funcionalidades incluidas

| Funcionalidad | Dónde está |
|---|---|
| 🔥 Inicio con película destacada y tendencias | `presentation/screens/home_screen.dart` |
| 🔎 Búsqueda + filtros (género, año, nota, plataforma) | `search_screen.dart` + `filter_sheet.dart` |
| 🎞️ Detalle: póster, sinopsis, reparto, valoración | `detail_screen.dart` |
| ▶️ Tráiler de YouTube embebido | `widgets/trailer_player.dart` |
| 📺 "¿Dónde ver?" (Netflix, Disney+...) | `widgets/watch_providers_row.dart` |
| ❤️ Favoritos guardados en el móvil (SQLite) | `data/datasources/favorites_local_datasource.dart` |
| 🌓 Modo oscuro/claro (se recuerda) | `providers/theme_provider.dart` |

---

## ⚙️ Ajustes útiles

Abre `lib/core/constants/api_constants.dart` para cambiar:
- **`language`** → idioma de los textos (`'es-ES'`, `'es-MX'`, `'en-US'`...).
- **`watchRegion`** → tu país para "¿dónde ver?" (`'ES'`, `'MX'`, `'AR'`...).

Y `lib/core/constants/app_constants.dart` para editar la lista de plataformas
del filtro.

---

## 🆘 Problemas frecuentes

- **"Falta tu clave de API"** → no pegaste la clave en el Paso 2, o está mal
  copiada.
- **Error 401** → tu clave de TMDB no es válida. Vuelve a copiarla.
- **No aparecen plataformas en "¿dónde ver?"** → esa película no está en
  streaming en tu región, o cambia `watchRegion` a tu país.
- **El tráiler no carga en iOS** → revisa que el `setup.sh` configuró el
  `Info.plist` (necesita Mac). Vuelve a ejecutarlo.
- **`setup.sh` no se ejecuta** → prueba con `bash setup.sh`.

---

## 🛠️ Configuración manual de plataforma (solo si NO usas `setup.sh`)

**Android** — en `android/app/src/main/AndroidManifest.xml`, dentro de
`<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
Y en `android/app/build.gradle.kts` pon `minSdk = 21`.

**iOS** — en `ios/Runner/Info.plist` añade:
```xml
<key>io.flutter.embedded_views_preview</key>
<true/>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```
