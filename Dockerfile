# Default Dockerfile - builds the WEB service
# Para los otros servicios, Railway usa RAILWAY_DOCKERFILE_PATH configurado en el dashboard
ARG JITSI_REPO=jitsi
ARG BASE_TAG=stable

FROM ${JITSI_REPO}/base:${BASE_TAG}

LABEL org.opencontainers.image.title="Jitsi Meet Web - Sigeres"

ADD https://raw.githubusercontent.com/acmesh-official/acme.sh/3.0.7/acme.sh /opt
COPY web/rootfs/ /

RUN apt-dpkg-wrap apt-get update && \
    apt-dpkg-wrap apt-get install -y dnsutils cron nginx-extras jitsi-meet-web socat curl jq && \
    mv /usr/share/jitsi-meet/interface_config.js /defaults && \
    rm -f /etc/nginx/conf.d/default.conf && \
    apt-cleanup

# Copiar overlays de Railway (sobreescribe templates con versión Railway + branding)
COPY railway/rootfs-web/ /

ENV DISABLE_HTTPS=1 \
    ENABLE_HTTP_REDIRECT=0 \
    ENABLE_COLIBRI_WEBSOCKET=1 \
    ENABLE_XMPP_WEBSOCKET=1 \
    ENABLE_IPV6=0

EXPOSE 80
