# Imagen pre-construida oficial de Jitsi para el frontend (nginx + jitsi-meet)
# Cambiar el tag (stable / unstable / stable-NNNN) segun la version deseada.
FROM jitsi/web:stable

# Railway inyecta PORT y espera que el servicio escuche en ese puerto.
# La imagen de jitsi/web sirve HTTP en el puerto 80 por defecto, redirigimos.
ENV HTTP_PORT=80
ENV HTTPS_PORT=443
ENV DISABLE_HTTPS=1
ENV ENABLE_HTTP_REDIRECT=0
ENV ENABLE_LETSENCRYPT=0

EXPOSE 80
