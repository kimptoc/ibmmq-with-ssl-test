Basic tester app to run ibm mq server (ssl 'should' be enabled)
and 2 test clients - one with ssl enabled and one without (which should and does fail)

To run it, use docker-compose like so:
```
$ docker-compose build && docker-compose up
```

Which should end with results like this, after 30 seconds (time configured for MQ to start)

```
mqclient    | SimplePubSub: Your lucky number today is 561
```

And it works!
  
 **TODO**
 
 - setup mutual ssl
 - using oracle jdk client
 - try v8 MQ