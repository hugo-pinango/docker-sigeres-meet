#!/usr/bin/env bash
set -euo pipefail

# Script para desplegar Jitsi Meet en Railway
# Requiere: railway CLI instalado y autenticado (railway login)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Desplegando Jitsi Meet en Railway ==="
echo ""

# Verificar que railway CLI está instalado
if ! command -v railway &> /dev/null; then
    echo "Error: Railway CLI no está instalado."
    echo "Instalar con: npm install -g @railway/cli"
    exit 1
fi

# Verificar login
if ! railway whoami &> /dev/null; then
    echo "Error: No estás autenticado en Railway."
    echo "Ejecuta: railway login"
    exit 1
fi

# Generar passwords si no existen
if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo ">>> Generando .env con passwords..."
    cp "$PROJECT_DIR/env.example" "$PROJECT_DIR/.env"
    bash "$PROJECT_DIR/gen-passwords.sh"
fi

# Leer passwords del .env
source "$PROJECT_DIR/.env"

echo ""
echo "=== Configuración detectada ==="
echo "JICOFO_AUTH_PASSWORD: ${JICOFO_AUTH_PASSWORD:0:8}..."
echo "JVB_AUTH_PASSWORD: ${JVB_AUTH_PASSWORD:0:8}..."
echo ""

# Variables compartidas
SHARED_VARS=(
    "JICOFO_AUTH_PASSWORD=$JICOFO_AUTH_PASSWORD"
    "JVB_AUTH_PASSWORD=$JVB_AUTH_PASSWORD"
    "XMPP_DOMAIN=meet.jitsi"
    "XMPP_AUTH_DOMAIN=auth.meet.jitsi"
    "XMPP_MUC_DOMAIN=muc.meet.jitsi"
    "XMPP_INTERNAL_MUC_DOMAIN=internal-muc.meet.jitsi"
    "XMPP_HIDDEN_DOMAIN=hidden.meet.jitsi"
    "XMPP_GUEST_DOMAIN=guest.meet.jitsi"
    "XMPP_SERVER=prosody.railway.internal"
    "XMPP_PORT=5222"
    "TZ=${TZ:-America/Bogota}"
)

echo "=== Instrucciones de despliegue manual ==="
echo ""
echo "Railway no soporta despliegue multi-servicio automatizado via CLI."
echo "Sigue estos pasos en el Dashboard de Railway (https://railway.app):"
echo ""
echo "1. Crea un nuevo proyecto"
echo "2. Añade 4 servicios desde este repositorio Git:"
echo ""
echo "   SERVICIO: prosody"
echo "   - Dockerfile path: railway/Dockerfile.prosody"
echo "   - Service name: prosody"
echo ""
echo "   SERVICIO: jicofo"
echo "   - Dockerfile path: railway/Dockerfile.jicofo"
echo "   - Service name: jicofo"
echo ""
echo "   SERVICIO: jvb"
echo "   - Dockerfile path: railway/Dockerfile.jvb"
echo "   - Service name: jvb"
echo ""
echo "   SERVICIO: web"
echo "   - Dockerfile path: railway/Dockerfile.web"
echo "   - Service name: web"
echo "   - Generar dominio público"
echo ""
echo "3. Configura las variables compartidas en el proyecto:"
echo ""
for var in "${SHARED_VARS[@]}"; do
    echo "   $var"
done
echo ""
echo "4. Variables adicionales por servicio:"
echo ""
echo "   [web]"
echo "   DISABLE_HTTPS=1"
echo "   ENABLE_HTTP_REDIRECT=0"
echo "   ENABLE_COLIBRI_WEBSOCKET=1"
echo "   ENABLE_XMPP_WEBSOCKET=1"
echo "   XMPP_BOSH_URL_BASE=http://prosody.railway.internal:5280"
echo "   COLIBRI_WEBSOCKET_JVB_LOOKUP_NAME=jvb.railway.internal"
echo "   PUBLIC_URL=<tu-dominio-railway>"
echo ""
echo "   [prosody]"
echo "   PROSODY_C2S_REQUIRE_ENCRYPTION=0"
echo ""
echo "   [jicofo]"
echo "   JICOFO_ENABLE_HEALTH_CHECKS=true"
echo "   JICOFO_ENABLE_REST=true"
echo ""
echo "   [jvb]"
echo "   ENABLE_COLIBRI_WEBSOCKET=1"
echo "   JVB_PORT=10000"
echo ""
echo "5. Habilitar Private Networking en todos los servicios"
echo "6. Deploy!"
echo ""
echo "=== Notas importantes ==="
echo "- El servicio 'web' es el único que necesita dominio público"
echo "- Railway maneja TLS automáticamente (por eso DISABLE_HTTPS=1)"
echo "- JVB usa WebSocket como transporte (Railway no soporta UDP nativamente)"
echo "- Si necesitas UDP para mejor calidad, considera un TURN server externo"
