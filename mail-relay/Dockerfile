# Dockerfile for a Postfix email relay service
FROM alpine:3.21
LABEL org.opencontainers.image.authors="juan@juanbaptiste.tech"

RUN apk update && \
    apk add --no-cache \
        bash \
        gawk \
        cyrus-sasl \
        cyrus-sasl-login \
        cyrus-sasl-crammd5 \
        mailx \
        tzdata \
        postfix && \
    rm -rf /var/cache/apk/* && \
    newaliases && \
    sed -i -e 's/inet_interfaces = localhost/inet_interfaces = all/g' /etc/postfix/main.cf

COPY run.sh /
RUN chmod +x /run.sh

EXPOSE 25
CMD ["/run.sh"]
