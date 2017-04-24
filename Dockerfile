FROM ibmcom/ibmjava:sdk


RUN mkdir -p /app/mqtest
WORKDIR /app/mqtest
ADD . /app/mqtest

CMD ["./src/try_mq.sh"]

