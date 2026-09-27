#!/usr/bin/env bash
# =============================================================================
#  setup.sh — Deja el proyecto Movie Hub listo para ejecutar.
#
#  Qué hace:
#    1. Comprueba que tienes Flutter instalado.
#    2. Genera las carpetas de plataforma que faltan (android/, ios/, etc.)
#       SIN tocar tu código de lib/ ni tu pubspec.yaml.
#    3. Ajusta la configuración de Android (permiso de Internet + minSdk).
#    4. Ajusta la configuración de iOS (permite el reproductor de YouTube).
#    5. Descarga las dependencias (flutter pub get).
#
#  Uso (desde la carpeta del proyecto, en tu Mac):
#     chmod +x setup.sh
#     ./setup.sh
# =============================================================================
set -e

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}==>${NC} $1"; }
warn()  { echo -e "${YELLOW}!! ${NC} $1"; }
error() { echo -e "${RED}✗  ${NC} $1"; }

# --- 1. Comprobar Flutter ---
if ! command -v flutter >/dev/null 2>&1; then
  error "No se encontró Flutter. Instálalo desde https://docs.flutter.dev/get-started/install"
  exit 1
fi
info "Flutter detectado: $(flutter --version | head -n 1)"

# --- 2. Generar plataformas sin pisar lib/ ni pubspec.yaml ---
info "Generando carpetas de plataforma (android/ios/...) ..."
# Guardamos temporalmente nuestros archivos para que flutter create no los sobrescriba.
TMPDIR_BAK="$(mktemp -d)"
cp -R lib "$TMPDIR_BAK/lib"
cp pubspec.yaml "$TMPDIR_BAK/pubspec.yaml"
[ -f analysis_options.yaml ] && cp analysis_options.yaml "$TMPDIR_BAK/analysis_options.yaml"

flutter create --org com.moviehub --project-name movie_hub --platforms=android,ios . >/dev/null

# Restauramos nuestros archivos (por si flutter create los regeneró).
rm -rf lib
cp -R "$TMPDIR_BAK/lib" lib
cp "$TMPDIR_BAK/pubspec.yaml" pubspec.yaml
[ -f "$TMPDIR_BAK/analysis_options.yaml" ] && cp "$TMPDIR_BAK/analysis_options.yaml" analysis_options.yaml
rm -rf "$TMPDIR_BAK"
info "Carpetas de plataforma listas."

# --- 3. Configurar Android ---
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ] && ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
  info "Añadiendo permiso de Internet en Android..."
  # Insertamos el permiso justo después de la etiqueta <manifest ...>
  perl -0pi -e 's/(<manifest[^>]*>)/$1\n    <uses-permission android:name="android.permission.INTERNET"\/>/' "$MANIFEST"
fi

# minSdk: el reproductor de YouTube necesita al menos 21.
GRADLE_KTS="android/app/build.gradle.kts"
GRADLE="android/app/build.gradle"
if [ -f "$GRADLE_KTS" ]; then
  info "Ajustando minSdk en Android (build.gradle.kts)..."
  perl -0pi -e 's/minSdk\s*=\s*flutter\.minSdkVersion/minSdk = 21/' "$GRADLE_KTS"
elif [ -f "$GRADLE" ]; then
  info "Ajustando minSdk en Android (build.gradle)..."
  perl -0pi -e 's/minSdkVersion\s+flutter\.minSdkVersion/minSdkVersion 21/' "$GRADLE"
fi

# --- 4. Configurar iOS ---
PLIST="ios/Runner/Info.plist"
PLISTBUDDY="/usr/libexec/PlistBuddy"
if [ -f "$PLIST" ] && [ -x "$PLISTBUDDY" ]; then
  info "Configurando iOS (Info.plist) para el reproductor de YouTube..."
  # Permitir vistas embebidas (necesario para el webview del reproductor).
  "$PLISTBUDDY" -c "Add :io.flutter.embedded_views_preview bool true" "$PLIST" 2>/dev/null || \
  "$PLISTBUDDY" -c "Set :io.flutter.embedded_views_preview true" "$PLIST" 2>/dev/null || true
  # Permitir cargas de red del reproductor.
  "$PLISTBUDDY" -c "Add :NSAppTransportSecurity dict" "$PLIST" 2>/dev/null || true
  "$PLISTBUDDY" -c "Add :NSAppTransportSecurity:NSAllowsArbitraryLoads bool true" "$PLIST" 2>/dev/null || \
  "$PLISTBUDDY" -c "Set :NSAppTransportSecurity:NSAllowsArbitraryLoads true" "$PLIST" 2>/dev/null || true
else
  warn "No se pudo configurar iOS automáticamente (¿no estás en Mac?). Si vas a usar iPhone, revisa el README, apartado iOS."
fi

# --- 5. Dependencias ---
info "Descargando dependencias (flutter pub get)..."
flutter pub get

echo ""
info "¡Listo! 🎬"
echo -e "${YELLOW}Antes de ejecutar:${NC} pega tu clave de TMDB en lib/core/constants/api_constants.dart"
echo -e "Luego conecta tu móvil o abre un emulador y ejecuta:  ${GREEN}flutter run${NC}"
