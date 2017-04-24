Basic tester app to run ibm mq server (ssl disabled) and the sample client.

To run it, use docker-compose like so:
```
$ docker-compose build && docker-compose up
```

Which should end with results like this, after 30 seconds (time configured for MQ to start)

```
mqclient    | SimplePubSub: Your lucky number today is 561
```