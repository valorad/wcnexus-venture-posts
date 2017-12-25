# example for building and running a countainer:
# docker build -t wcnexus-venture .
# docker run --name wcnexus-venture-c1 \
# -v /path/to/this/repo/wcnexus-venture:/src \
# -v /path/to/local/output:/dist wcnexus-venture 

FROM alpine:latest
LABEL maintainer="Valroad <valorad@outlook.com>"

RUN apk update \
 && apk add hugo git \
 && rm -rf /var/cache/apk/*

RUN git clone https://github.com/valorad/wcnexus-venture.git /src \
# Theme update
 && echo "Fetch latest wcn-theme..." \
 && rm -rf /src/themes/* \
 && wget -O /tmp/theme.zip https://github.com/$(wget https://github.com/valorad/wcnexus-venture-theme/releases/latest -O - | egrep '/.*releases/.*/.*zip' -o) \
 && mkdir -p /src/themes/wcnexus-venture \
 && unzip -d /src/themes/wcnexus-venture/ /tmp/theme.zip

VOLUME [ "/src", "/dist" ]

WORKDIR /src

ENTRYPOINT ["/src/index.sh"]
# CMD [ "hugo", "-s", "/src", "-d", "/dist" ]
CMD git pull && hugo -s /src -d /dist