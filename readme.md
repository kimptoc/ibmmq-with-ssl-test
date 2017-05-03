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

For the Oracle Java with SSL example (currently not working):
```
$ docker-compose.exe up ibmmq mqclientoracle
```


Which should end with results like this, after 30 seconds (time configured for MQ to start)

```
mqclient    | SimplePubSub: Your lucky number today is 561
```

And it works!
  
 **TODO**
 
 - using oracle jdk client with SSL
 - setup mutual ssl (IBM and Java)
 - try v8 MQ