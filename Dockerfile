FROM ibmcom/ibmjava:sdk


RUN mkdir -p /app/mqtest
WORKDIR /app/mqtest
ADD . /app/mqtest

RUN sed 's/\r//' src/try_mq.sh > try_mq_tweaked.sh

CMD ["bash","try_mq_tweaked.sh"]
