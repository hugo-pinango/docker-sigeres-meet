# Videobridge: enruta los streams de medios WebRTC.
# AVISO: requiere UDP/10000 publico para funcionar de forma optima.
# Railway no expone UDP en planes estandar; ver railway/jvb/railway.json
# y el bloque de variables JVB en env.railway.example para forzar TCP/443.
FROM jitsi/jvb:stable

EXPOSE 10000/udp 4443/tcp 8080/tcp
