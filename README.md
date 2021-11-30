# curly-queue
Send an http request with curl and it's scheduled to run via sqs. Allows you to make long running http requests to any endpoint reachable from your container. Can be run as a background process(just run start.sh), a standalone container or as a sidecar container.

## Requirements
- docker
- aws cli installed locally
- docker-compose(for local testing)

### Docker

The dockerfile has most of the utilities needed to run the script but will need some configuration to be able to connect to a localstack sqs queue instead of a real one. It's fairly close but a WIP. 


### Local Testing

start local stack:
```
docker-compose up
```

create queue named myqueue
```
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name myqueue
```

Add a message to the queue

```
aws sqs send-message --endpoint-url http://localhost:4566 --queue-url 'http://localhost:4566/000000000000/myqueue' --message-body "start" | cat
```

in another terminal tab, run the start script
```
sh start.sh 'https://google.com'

```

You can start up multiple instances of `start.sh` and each instance will coordinate executing the curl commands through SQS and clearing the queue once its done.

To try it out with a slow running HTTP request, try to forward the URL through a time delay proxy(in milliseconds), with the command below. Note: its useful for testing out time delays but anything beyond a minute you will need to run your own slow running proxy the service rate limits.
```
sh start.sh 'https://deelay.me/3000/https://google.com'
```

Modify the variables at the top of the script in the start.sh to customize the options further. Will likely be switched to environment variables in some places since this would make it easier to run and customize with container scheduling  or as a script.
