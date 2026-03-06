ARG IMAGE_BASE=redhat/ubi8:8.5-236
# hadolint ignore=DL3006
FROM ${IMAGE_BASE}

LABEL version="3.7.0"
LABEL description="TOTVS LicenseServer" 
LABEL maintainer="Julian de Almeida Santos <julian.santos.info@gmail.com>"

ENV LICENSE_TCP_PORT=2234
ENV LICENSE_CONSOLEFILE=/totvs/licenseserver/bin/appserver/licenseserver.log
ENV LICENSE_PORT=5555
ENV LICENSE_WEBAPP_PORT=8020
ENV DEBUG_SCRIPT=false
ENV TZ=America/Sao_Paulo

COPY ./totvs /totvs
COPY ./entrypoint.sh ./healthcheck.sh ./install.sh /

RUN chmod +x /entrypoint.sh /healthcheck.sh /install.sh && \
    PKG_MGR=$(command -v dnf || command -v microdnf) && \
    $PKG_MGR update -y && \
    $PKG_MGR install -y java && \
    /install.sh && \
    $PKG_MGR clean all && \
    rm -rf /var/cache/dnf

ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 2234 4000 5555 8020