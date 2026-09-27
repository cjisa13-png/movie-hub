# 📱 Cómo instalar Movie Hub en tu móvil Android (sin ordenador)

Como una app de móvil no se puede abrir con un simple enlace de web, hay que
"compilarla" una vez. Lo más fácil sin tener que instalar nada en tu ordenador
es dejar que **GitHub la compile gratis en la nube** y te dé un enlace de
descarga. Aquí tienes los pasos.

> ⏱️ La primera vez son unos 10 minutos de clics. Después, cada mejora del
> código genera un APK nuevo automáticamente.

---

## Opción A — GitHub compila el APK por ti (recomendada) ✅

### 1. Crea una cuenta gratis en GitHub
- Entra en https://github.com/signup y crea tu cuenta (gratis).

### 2. Crea un repositorio vacío
- Pulsa el **+** arriba a la derecha → **New repository**.
- Ponle un nombre (por ejemplo `movie-hub`), déjalo en **Private** o **Public**
  (da igual) y pulsa **Create repository**. No marques ninguna casilla extra.

### 3. Sube el proyecto
Tienes dos formas:

**Forma fácil (desde el navegador):**
- En la página del repositorio recién creado, pulsa
  **"uploading an existing file"**.
- Arrastra **todo el contenido** de la carpeta `movie_hub` (no la carpeta en sí,
  sino lo que hay dentro). Incluye las carpetas ocultas `.github` y `android`.
- Pulsa **Commit changes**.

> 💡 Si prefieres, dile a Claude que **conecte tu GitHub** y que suba el
> proyecto por ti; así te saltas este paso.

### 4. Espera a que se compile
- Ve a la pestaña **Actions** del repositorio. Verás un proceso llamado
  "Compilar APK de Android" en marcha (círculo amarillo).
- Cuando termine (unos 5-8 min) se pondrá un tic verde ✅.

### 5. Descarga el APK en tu móvil
- Con el móvil, abre la página de tu repositorio y entra en **Releases**
  (a la derecha), o ve directamente a:
  `https://github.com/TU_USUARIO/TU_REPO/releases/latest`
- Descarga el archivo **`app-release.apk`**.
- Ábrelo. Android te pedirá permiso para "instalar apps de orígenes
  desconocidos": acéptalo e instala.

### 6. Abre la app y pega tu clave de TMDB
- Al abrirla por primera vez, la app te pedirá tu clave gratuita de TMDB.
  Sigue los pasos que verás en pantalla (crear cuenta en themoviedb.org y
  copiar la clave). ¡Y listo! 🎬

---

## Opción B — Compilarla en tu propio ordenador

Si algún día instalas Flutter en tu Mac/PC, es aún más directo:
```bash
cd movie_hub
flutter pub get
flutter build apk --release
```
El APK queda en `build/app/outputs/flutter-apk/app-release.apk`. Pásalo a tu
móvil (por cable, Google Drive, WhatsApp Web...) y ábrelo para instalarlo.

---

## ❓ Preguntas rápidas

- **¿Es seguro instalar un APK así?** Sí, es tu propia app compilada desde tu
  propio código. El aviso de "orígenes desconocidos" es lo normal para apps que
  no vienen de la Play Store.
- **¿Puedo subirla a la Play Store?** Sí, pero eso requiere una cuenta de
  desarrollador de Google (pago único de 25 $) y algunos pasos más. Para uso
  personal no hace falta.
- **¿Y para iPhone?** Apple no permite instalar apps así de fácil; necesita un
  Mac con Xcode o una cuenta de desarrollador de Apple.
