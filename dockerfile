# example for building and running a countainer:
# docker build -t wcnventure .
# docker run --name wcnventureC1 -v /workspace/www:/dist wcnventure
FROM alpine:latest
LABEL maintainer="Valroad <valorad@outlook.com>"

RUN    apk update \
    && apk add hugo \
    && rm -rf /var/cache/apk/*

VOLUME [ "/src" ]
VOLUME [ "/dist" ]

COPY . /src/

WORKDIR /src

ENTRYPOINT [ "hugo" ]
CMD [ "-d", "/dist" ]