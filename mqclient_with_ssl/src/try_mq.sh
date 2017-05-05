#!/usr/bin/env bash

echo "Running try_mq.sh"

#ls -ltr /opt/mqm/java/lib

export MQ_CP="`echo /opt/mqm/java/lib/*.jar | sed 's/ /:/g'`"

echo "Compiling Java code"

mkdir -p out/main/java

javac -cp $MQ_CP -d out/main/java src/main/java/*

ls -ltr out/main/java


echo "Lets give MQ time to start"

sleep 25

echo "Running Java code"

export JAVA_OPTS=""
#export JAVA_OPTS="-Djavax.net.ssl.trustStore=./keystore.jks -Djavax.net.ssl.keyStore=./keystore.jks -Djavax.net.ssl.trustStorePassword=ABCDEF -Djavax.net.ssl.keyStorePassword=ABCDEF "

# trust store has the server certificate in it
export JAVA_OPTS="$JAVA_OPTS -Djavax.net.ssl.trustStore=/etc/mqcerts/keystore.jks -Djavax.net.ssl.trustStorePassword=ABCDEF "
# key store has the client certificate in it - need to gen/send this to the server # TODO
#export JAVA_OPTS="$JAVA_OPTS -Djavax.net.ssl.keyStore=./keystore.jks -Djavax.net.ssl.keyStorePassword=ABCDEF "
export JAVA_OPTS="$JAVA_OPTS -Dcom.ibm.mq.cfg.useIBMCipherMappings=false -Dcom.ibm.mq.cfg.preferTLS=true"

java -version

java $JAVA_OPTS -cp $MQ_CP:out/main/java SimplePubSub

sleep 300 # keep container running for investigations