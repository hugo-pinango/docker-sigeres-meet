# Servidor XMPP que orquesta la senalizacion entre web/jicofo/jvb.
FROM jitsi/prosody:stable

# Puertos expuestos por defecto en la imagen:
#   5222 -> XMPP c2s (clientes: jicofo, jvb)
#   5269 -> XMPP s2s
#   5347 -> componentes externos
#   5280 -> BOSH / WebSocket HTTP (lo consume nginx en `web`)
EXPOSE 5222 5269 5280 5347
