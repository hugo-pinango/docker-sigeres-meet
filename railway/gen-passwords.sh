#!/usr/bin/env bash
# Genera contrasenas fuertes y un secreto de componente para pegar en
# las variables compartidas del proyecto en Railway.

set -euo pipefail

generate() { openssl rand -hex 16; }

cat <<EOF
# === Pega esto en Railway -> Project -> Variables (Shared) ===
JICOFO_AUTH_PASSWORD=$(generate)
JVB_AUTH_PASSWORD=$(generate)
JICOFO_COMPONENT_SECRET=$(generate)
JIGASI_XMPP_PASSWORD=$(generate)
JIBRI_RECORDER_PASSWORD=$(generate)
JIBRI_XMPP_PASSWORD=$(generate)
JIGASI_TRANSCRIBER_PASSWORD=$(generate)
EOF
