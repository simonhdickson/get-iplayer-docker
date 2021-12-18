FROM alpine:latest

RUN addgroup -g 1000 app

RUN adduser -D -s /bin/sh -u 1000 -G app app

RUN apk --update add \
    ffmpeg \
    openssl \
    perl-mojolicious \
    perl-lwp-protocol-https \
    perl-xml-simple \
    perl-xml-libxml \
    perl-cgi

RUN mkdir -p /data/output /data/config

WORKDIR /app

ENV GET_IPLAYER_VERSION=3.28
ENV GETIPLAYERUSERPREFS="/data/config"
ENV IPLAYER_OUTDIR="/data/downloads"

RUN wget -qO- https://github.com/get-iplayer/get_iplayer/archive/v${GET_IPLAYER_VERSION}.tar.gz | tar -xvz -C /tmp && \
    mv /tmp/get_iplayer-${GET_IPLAYER_VERSION}/get_iplayer . && \
    mv /tmp/get_iplayer-${GET_IPLAYER_VERSION}/get_iplayer.cgi . && \
    rm -rf /tmp/* && \
    chmod +x ./get_iplayer && \
    chmod +x ./get_iplayer.cgi

RUN chown -R app:app ./

USER app

EXPOSE 5000

ENTRYPOINT ["./get_iplayer.cgi", "--listen", "0.0.0.0", "--port", "5000", "--ffmpeg", "/usr/bin/ffmpeg"]
