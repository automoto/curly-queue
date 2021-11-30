#!/bin/bash
POLL=2

# should set so the max request time for the curl call and the visbility timeout are close. that way when the request times out, the sqs message gets sent back to the queue
MAX_PROCESS_TIME=5

# make the cURL request cutoff slightly before the visibility timeout
MAX_CURL_REQUEST_WAIT="$(($MAX_PROCESS_TIME-1))"

# Max value for this is 20 seconds as per AWS https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/working-with-messages.html#setting-up-long-polling
MAX_SQS_WAIT_TIME=20

TARGET_HTTP_STATUS=200

# LOCALSTACK URLS, probably not needed for prod
QUEUE_URL='http://localhost:4566/000000000000/myqueue'
ENDPOINT_URL='http://localhost:4566'

while sleep $POLL; do \
	echo "Checking for messages in the queue..."
	RCPT_HNDL=$(aws sqs receive-message --wait-time $MAX_SQS_WAIT_TIME --visibility-timeout $MAX_PROCESS_TIME --endpoint-url $ENDPOINT_URL --queue-url $QUEUE_URL | jq -r '.Messages[] | .ReceiptHandle');
	if [ -n "$RCPT_HNDL" ]; then
		echo "Starting cURL request of URL $1"
		# note: -L is used here because we want to follow a redirect and get the final HTTP response
		CURL_STATUS=$(curl -L --max-time $MAX_CURL_REQUEST_WAIT --write-out %{http_code} --silent --output /dev/null $1)
		# if not the http code we specify, print a status message
		if [[ "$CURL_STATUS" -ne $TARGET_HTTP_STATUS ]] ; then
			echo "cURL http status code was not the target $TARGET_HTTP_STATUS, trying again..."
		# else our request succeeded, print a message and remove queue message now were finished
		else 
			echo "cURL Request completed succesfully with http status $CURL_STATUS"
			echo "Deleting Message From Queue $RCPT_HNDL";
			aws sqs delete-message --endpoint-url http://localhost:4566 --queue-url 'http://localhost:4566/000000000000/myqueue' --receipt-handle $RCPT_HNDL;
		fi
	fi
	echo "polling $POLL seconds..."
done
