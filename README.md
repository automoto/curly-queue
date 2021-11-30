# curly-queue
Container for running a curl script that is scheudled to run via sqs. Allowss you to make long running http requests to any endpoint reachable from your container. Can be ride as a script as a background process, a standalone container or as a sidecar.

## Requirements
- docker
- aws cli installed locally
- docker-compose(for local testing)


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

To try it out with a slow running HTTP request, try to forward the URL through a time delay proxy(in milliseconds), try out the command below. Note: its useful for testing out time delays but anything beyond a minute you will need to run your own slow running proxy the service rate limits.
```
sh start.sh 'https://deelay.me/3000/https://google.com'
```

Modify the variables at the top of the script in the start.sh to customize the options further. Will likely be switched to environment variables in some places since this would make it easier to run and customize with container scheduling  or as a script.
