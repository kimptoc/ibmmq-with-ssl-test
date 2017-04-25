FROM ibmcom/ibmjava:sdk

RUN mkdir -p /app/mqtest
WORKDIR /app/mqtest
ADD . /app/mqtest

RUN sed 's/\r//' src/try_mq_no_ssl.sh > try_mq_no_ssl_tweaked.sh

CMD ["bash","try_mq_no_ssl_tweaked.sh"]
