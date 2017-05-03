# keytool in this image is not on path
FROM isuper/java-oracle:jdk_8

# this is openjdk
#FROM java

# use unlimited jurisdiction policy files
# RUN cp /opt/ibm/java/demo/jce/policy-files/unrestricted/* /opt/ibm/java/jre/lib/security/

RUN mkdir -p /app/mqtest
WORKDIR /app/mqtest
ADD . /app/mqtest

RUN sed 's/\r//' src/try_mq.sh > try_mq_tweaked.sh

CMD ["bash","try_mq_tweaked.sh"]
