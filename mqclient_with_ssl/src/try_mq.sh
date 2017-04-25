#!/usr/bin/env bash

echo "Running try_mq.sh"

#ls -ltr /opt/mqm/java/lib

export MQ_CP="`echo /opt/mqm/java/lib/*.jar | sed 's/ /:/g'`"

echo "Compiling Java code"

mkdir -p out/main/java

javac -cp $MQ_CP -d out/main/java src/main/java/*

ls -ltr out/main/java


echo "Convert pkcs12 keystore to jks"

ls -ltr /etc/mqcerts

keytool -importkeystore -noprompt -srckeystore /etc/mqcerts/keystore.p12 -srcstoretype pkcs12 -srcalias myAlias -srcstorepass x -destkeystore ./keystore.jks -deststoretype jks -deststorepass ABCDEF -destalias myAlias

ls -ltr

echo "Lets give MQ time to start"

sleep 180

echo "Running Java code"

export JAVA_OPTS="-Djavax.net.ssl.trustStore=./keystore.jks -Djavax.net.ssl.keyStore=./keystore.jks -Djavax.net.ssl.trustStorePassword=ABCDEF -Djavax.net.ssl.keyStorePassword=ABCDEF -Dcom.ibm.mq.cfg.useIBMCipherMappings=false -Dcom.ibm.mq.cfg.preferTLS=true"

java $JAVA_OPTS -cp $MQ_CP:out/main/java SimplePubSub
