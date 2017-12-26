# example for building and running a countainer:
# docker build -t wcnexus-venture .
# docker run --name wcnexus-venture-c1 \
# -e EXEC_USER=$USER -e EXEC_USER_ID=$UID \
# -v /path/to/local/output:/dist \
# wcnexus-venture 

FROM alpine:latest
LABEL maintainer="Valroad <valorad@outlook.com>"

RUN apk update \
 && apk add hugo git su-exec \
 && rm -rf /var/cache/apk/*

RUN git clone https://github.com/valorad/wcnexus-venture.git /src \
# Theme update
 && echo "Fetch latest wcn-theme..." \
 && wget -O /tmp/theme.zip https://github.com/$(wget https://github.com/valorad/wcnexus-venture-theme/releases/latest -O - | egrep '/.*releases/.*/.*zip' -o) \
 && mkdir -p /src/themes/wcnexus-venture \
 && unzip -d /src/themes/wcnexus-venture/ /tmp/theme.zip \
 && rm -rf /tmp/* \
 && chmod 777 /src/index.sh

VOLUME [ "/src", "/dist" ]

WORKDIR /src

ENTRYPOINT ["/src/index.sh"]
CMD git checkout . && git pull && hugo -s /src -d /dist