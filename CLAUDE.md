# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a customized fork of [docker-jitsi-meet](https://github.com/jitsi/docker-jitsi-meet) — Docker Compose setup for deploying a Jitsi Meet videoconferencing stack. The project name is "sigeres-meet".

## Architecture

The stack consists of four core services orchestrated via `docker-compose.yml`, all on the `meet.jitsi` Docker network:

- **web** — Nginx-based frontend serving the Jitsi Meet web app (ports 80/443)
- **prosody** — XMPP server handling signaling and authentication
- **jicofo** — Conference focus component (Java) that manages ofedrences and bridges
- **jvb** — Jitsi Videobridge (Java) handling actual media routing (UDP port 10000)

Optional services are defined in separate compose files: `jibri.yml` (recording), `jigasi.yml` (SIP gateway), `transcriber.yml`, `etherpad.yml` (shared documents), `whiteboard.yml` (Excalidraw), `rtcstats.yml`, `grafana.yml`, `prometheus.yml`, `log-analyser.yml`.

Each service has its own directory (`web/`, `prosody/`, `jicofo/`, `jvb/`, `jibri/`, `jigasi/`) containing a `Dockerfile` and a `rootfs/` tree that gets copied into the image. Base images are in `base/` and `base-java/`.

## Common Commands

```bash
# Initial setup: copy env.example to .env, then generate passwords
cp env.example .env
./gen-passwords.sh

# Start the core stack
docker compose up -d

# Start with optional services (e.g., recording + etherpad)
docker compose -f docker-compose.yml -f jibri.yml -f etherpad.yml up -d

# Build all images locally
make build-all

# Build a single service image (e.g., web, prosody, jicofo, jvb, jibri, jigasi)
make build_web
make build_prosody

# Force rebuild without cache
FORCE_REBUILD=1 make build-all

# Stop and clean up
make clean
```

## Configuration

All configuration is done through environment variables in `.env` (created from `env.example`). The `gen-passwords.sh` script populates the required XMPP passwords. Full options reference: https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-docker

Key variables: `PUBLIC_URL`, `HTTP_PORT`, `HTTPS_PORT`, `ENABLE_AUTH`, `AUTH_TYPE`, `JITSI_IMAGE_VERSION`, `JVB_ADVERTISE_IPS`.

## Local Modifications

Volume mounts in `docker-compose.yml` are commented out — this deployment currently relies on baked-in image configuration rather than host-mounted config volumes.
