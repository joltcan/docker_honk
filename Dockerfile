FROM alpine:latest

LABEL maintainer="Fredrik Lundhag <f@mekk.com>"

EXPOSE 31337

VOLUME ["/config"]

RUN apk add --no-cache expect sqlite-libs

ADD passwd.minimal /etc/passwd

ADD honk /
ADD views /views
ADD honk-entrypoint.sh /
ADD honk-init.exp /

WORKDIR "/"

USER honk

ENTRYPOINT ["/honk-entrypoint.sh"]

CMD ["run"]
