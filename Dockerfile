ARG BUILD_DATE=""
ARG ARCH=amd64
ARG PYTHON_VERSION=3
ARG SYNAPSE_VERSION="0.34.0"

###
### Stage 0: builder
###
FROM docker.io/${ARCH}/python:${PYTHON_VERSION}-alpine3.8 as builder

# install the OS build deps

RUN apk add \
        build-base \
        libffi-dev \
        libjpeg-turbo-dev \
        libressl-dev \
        libxslt-dev \
        linux-headers \
        postgresql-dev \
        zlib-dev

RUN pip install --prefix="/install" --no-warn-script-location \
        cryptography \
        msgpack-python \
        pillow \
        lxml \
        psycopg2 \
        pynacl

# now install synapse and all of the python deps to /install.

ARG SYNAPSE_VERSION
RUN pip install --prefix="/install" --no-warn-script-location \
        matrix-synapse==$SYNAPSE_VERSION

###
### Stage 1: runtime
###

FROM docker.io/${ARCH}/python:${PYTHON_VERSION}-alpine3.8

RUN apk add --no-cache --virtual .runtime_deps \
        libffi \
        libjpeg-turbo \
        libressl \
        libxslt \
        libpq \
        zlib \
        su-exec

COPY --from=builder /install /usr/local
COPY . /

VOLUME ["/data"]

EXPOSE 8008/tcp 8448/tcp 9000/tcp

ARG SYNAPSE_VERSION
ARG PYTHON_VERSION
ARG BUILD_DATE
LABEL org.opencontainers.image.title="Matrix Synapse (Python ${PYTHON_VERSION})" \
      org.opencontainers.image.description="Reference homeserver for the Matrix decentralised comms protocol" \
      org.opencontainers.image.authors="Quentin Gliech <quentingliech@gmail.com>" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.source="https://github.com/sandhose/docker-synapse" \
      org.opencontainers.image.version="${SYNAPSE_VERSION}"

ENTRYPOINT []
CMD ["python", "/run.py"]
