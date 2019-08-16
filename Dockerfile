FROM alpine:latest

RUN apk --update --no-cache add \
    bash openssl && mkdir /ca

COPY entrypoint.sh /bin/entrypoint.sh

VOLUME /ca/

ENTRYPOINT ["/bin/entrypoint.sh"]