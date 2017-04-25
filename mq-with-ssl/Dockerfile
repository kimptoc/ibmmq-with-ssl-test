FROM ibmcom/mq

ENV LICENSE=accept
ENV MQ_QMGR_NAME=QM1

ARG http_proxy

RUN apt-get update
RUN apt-get install openssl

RUN mkdir -p /etc/mqcerts
WORKDIR /etc/mqcerts
ADD . /etc/mqcerts

RUN openssl req -batch -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem

RUN echo "x" >openssl.params
RUN echo "x" >>openssl.params

RUN openssl pkcs12 -export -password file:openssl.params  -in cert.pem -inkey key.pem  -out keystore.p12 -name myAlias

ENV MQ_TLS_KEYSTORE=/etc/mqcerts/keystore.p12
ENV MQ_TLS_PASSPHRASE=x

#CMD ["ls","-ltr"]

