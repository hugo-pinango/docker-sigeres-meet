# Despliegue en Railway

## Arquitectura en Railway

Railway no soporta Docker Compose directamente. Cada servicio se despliega como un **servicio independiente** dentro de un mismo proyecto Railway. Los servicios se comunican entre sí usando la red privada interna de Railway (`*.railway.internal`).

## Servicios necesarios

| Servicio | Tipo | Puerto público | Puerto privado |
|----------|------|---------------|----------------|
| web | Docker | 443 (HTTPS via Railway) | 80 |
| prosody | Docker | — | 5222, 5280 |
| jicofo | Docker | — | 8888 |
| jvb | Docker | UDP 10000 | 8080 |

## Pasos para desplegar

### 1. Crear el proyecto en Railway

```bash
# Instalar Railway CLI si no lo tienes
npm install -g @railway/cli

# Login
railway login

# Crear proyecto
railway init
```

### 2. Configurar variables de entorno compartidas

En Railway Dashboard, crea las siguientes variables compartidas (Shared Variables) en el proyecto:

```env
# Generar passwords seguros (usa ./gen-passwords.sh localmente y copia los valores)
JICOFO_AUTH_PASSWORD=<generado>
JVB_AUTH_PASSWORD=<generado>

# Dominio público (Railway te asignará uno o usa tu dominio custom)
PUBLIC_URL=https://tu-dominio.up.railway.app

# Dominios XMPP internos
XMPP_DOMAIN=meet.jitsi
XMPP_AUTH_DOMAIN=auth.meet.jitsi
XMPP_MUC_DOMAIN=muc.meet.jitsi
XMPP_INTERNAL_MUC_DOMAIN=internal-muc.meet.jitsi
XMPP_HIDDEN_DOMAIN=hidden.meet.jitsi
XMPP_GUEST_DOMAIN=guest.meet.jitsi

# Hostname interno de Prosody en Railway
XMPP_SERVER=prosody.railway.internal
XMPP_BOSH_URL_BASE=http://prosody.railway.internal:5280

TZ=America/Bogota
```

### 3. Desplegar cada servicio

Cada servicio tiene su propio `Dockerfile.railway` en la carpeta `railway/`. Configura cada uno en el Dashboard de Railway apuntando al Dockerfile correcto.

**Orden de despliegue:**
1. `prosody` (primero — es el servidor XMPP)
2. `jicofo` (necesita prosody)
3. `jvb` (necesita prosody)
4. `web` (necesita todos los demás)

### 4. Configuración de red

- **web**: Habilitar dominio público en Railway (genera HTTPS automáticamente)
- **prosody**: Solo red privada (puerto 5222 y 5280)
- **jicofo**: Solo red privada (puerto 8888)
- **jvb**: Necesita puerto UDP público (10000) — configurar en Railway TCP/UDP proxy

### 5. Problema conocido: UDP en Railway

Railway tiene soporte limitado para UDP. JVB necesita UDP port 10000 para el tráfico de media WebRTC. Opciones:

1. **TCP fallback**: Habilitar `ENABLE_COLIBRI_WEBSOCKET=1` para que los clientes usen WebSocket en lugar de UDP (mayor latencia pero funcional)
2. **TURN server externo**: Configurar un servidor TURN que haga relay del tráfico UDP
3. **Railway TCP Proxy**: Usar el proxy TCP de Railway como fallback

La opción recomendada para Railway es usar **Colibri WebSocket** (opción 1).

## Variables por servicio

### prosody
```env
XMPP_SERVER=prosody.railway.internal
# (usa las shared variables del proyecto)
```

### jicofo
```env
XMPP_SERVER=prosody.railway.internal
XMPP_PORT=5222
JICOFO_ENABLE_HEALTH_CHECKS=true
```

### jvb
```env
XMPP_SERVER=prosody.railway.internal
XMPP_PORT=5222
JVB_PORT=10000
ENABLE_COLIBRI_WEBSOCKET=1
COLIBRI_WEBSOCKET_PORT=9090
JVB_ADVERTISE_IPS=<IP pública de Railway si disponible>
```

### web
```env
XMPP_BOSH_URL_BASE=http://prosody.railway.internal:5280
COLIBRI_WEBSOCKET_JVB_LOOKUP_NAME=jvb.railway.internal
ENABLE_COLIBRI_WEBSOCKET=1
ENABLE_XMPP_WEBSOCKET=1
DISABLE_HTTPS=1
ENABLE_HTTP_REDIRECT=0
```

> **Nota**: `DISABLE_HTTPS=1` porque Railway maneja TLS en su edge/proxy automáticamente.
