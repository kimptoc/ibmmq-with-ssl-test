#!/usr/bin/env bash

echo "Running try_mq.sh"

#ls -ltr /opt/mqm/java/lib

export MQ_CP="`echo /opt/mqm/java/lib/*.jar | sed 's/ /:/g'`"

echo "Compiling Java code"

javac -cp $MQ_CP -d out/main/java src/main/java/*

ls -ltr out/main/java

echo "Lets give MQ time to start"

sleep 30

echo "Running Java code"

#java -cp $MQ_CP:out/main/java HelloWorld
java -cp $MQ_CP:out/main/java SimplePubSub
