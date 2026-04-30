#!/usr/bin/env bash
set -euo pipefail

# Script para desplegar todos los servicios de Jitsi Meet en Railway
# Intercambia el Dockerfile raíz temporalmente para cada servicio

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ORIGINAL_DOCKERFILE="$PROJECT_DIR/Dockerfile"
BACKUP_DOCKERFILE="$PROJECT_DIR/Dockerfile.web.bak"

cleanup() {
    if [ -f "$BACKUP_DOCKERFILE" ]; then
        mv "$BACKUP_DOCKERFILE" "$ORIGINAL_DOCKERFILE"
        echo ">>> Restaurado Dockerfile original (web)"
    fi
}
trap cleanup EXIT

deploy_service() {
    local service=$1
    local dockerfile=$2

    echo ""
    echo "=== Desplegando $service ==="

    # Backup del Dockerfile actual y copiar el del servicio
    cp "$ORIGINAL_DOCKERFILE" "$BACKUP_DOCKERFILE"
    cp "$PROJECT_DIR/$dockerfile" "$ORIGINAL_DOCKERFILE"

    # Link y deploy
    railway service link "$service"
    railway up --detach

    # Restaurar
    mv "$BACKUP_DOCKERFILE" "$ORIGINAL_DOCKERFILE"

    echo ">>> $service: build iniciado"
}

echo "=== Deploy Jitsi Meet (Sigeres) en Railway ==="

# Desplegar en orden de dependencia
deploy_service "prosody" "railway/Dockerfile.prosody"
deploy_service "jicofo" "railway/Dockerfile.jicofo"
deploy_service "jvb" "railway/Dockerfile.jvb"

# Web usa el Dockerfile raíz directamente
echo ""
echo "=== Desplegando web ==="
railway service link web
railway up --detach
echo ">>> web: build iniciado"

echo ""
echo "=== Todos los builds iniciados ==="
echo "Verifica el estado con: railway service list"
