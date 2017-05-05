Basic tester app to run ibm mq server (ssl 'should' be enabled)
and 2 test clients - one with ssl enabled and one without (which should and does fail)

To run it, use docker-compose like so, for the ssl one sided example:
```
$ docker-compose up ibmmq mqclient
```

For the no SSL example:
```
$ docker-compose up ibmmqnossl mqclientnossl
```

For the Oracle Java without SSL example:
```
$ docker-compose up ibmmqnossl mqclientoraclenossl
```

For the Oracle Java with SSL example:
```
$ docker-compose.exe up ibmmq mqclientoracle
```


Which should end with results like this, after 30 seconds (time configured for MQ to start)

```
mqclient    | SimplePubSub: Your lucky number today is 561
```

And it works!
  
 **TODO**

 - setup mutual ssl (IBM and Java)
 - try v8 MQ
 
 **NOTES**
 
 - define certs_mount env variable before running docker-compose so that generated certs are visible outside of container
 - recommend you docker-compose stop/rm the containers between test runs - as the mq server can out of sync with the cert files
 - the exposed certs don't seem to work with MQ explorer, but work fine with a Java client app :(
 