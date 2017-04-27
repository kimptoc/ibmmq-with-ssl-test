FROM ibmcom/ibmjava:sdk

# use unlimited jurisdiction policy files
RUN cp /opt/ibm/java/demo/jce/policy-files/unrestricted/* /opt/ibm/java/jre/lib/security/

RUN mkdir -p /app/mqtest
WORKDIR /app/mqtest
ADD . /app/mqtest

RUN sed 's/\r//' src/try_mq.sh > try_mq_tweaked.sh

CMD ["bash","try_mq_tweaked.sh"]
