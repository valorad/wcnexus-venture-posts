# example for building and running a countainer:
# docker build -t wcnexus-venture .
# docker run --name wcnexus-venture-c1 -v /workspace/workbench/wcnexus-venture:/src -v /workspace/www/venture:/dist wcnexus-venture
FROM alpine:latest
LABEL maintainer="Valroad <valorad@outlook.com>"

RUN    apk update \
    && apk add hugo \
    && rm -rf /var/cache/apk/*

VOLUME [ "/src" ]
VOLUME [ "/dist" ]

WORKDIR /src

ENTRYPOINT [ "hugo" ]
CMD [ "-s", "/src", "-d", "/dist" ]