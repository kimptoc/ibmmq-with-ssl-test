FROM ibmcom/mq

ENV LICENSE=accept
ENV MQ_QMGR_NAME=QM1

ARG http_proxy

RUN apt-get update
RUN apt-get install openssl

VOLUME /etc/mqcerts

COPY *.sh /usr/local/bin/

COPY mq-dev-config /etc/mqm/mq-dev-config

