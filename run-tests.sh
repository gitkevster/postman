#!/bin/bash

# Send a test started message to the Slack regression channel
curl -X POST --data-urlencode "payload={\"username\": \"automation-bot\", \"text\": \"Test #$TRAVIS_JOB_NUMBER *STARTED* for *$TESTFOLDER* in repo: *$TRAVIS_REPO_SLUG*\"}" $SLACK_URL

# Run the postman collection with the associated environment for the test
POSTMAN_COLLECTION=$(find $TESTFOLDER -regex ".*/*postman_collection.json")
POSTMAN_ENVIRONMENT=$(find $TESTFOLDER -regex ".*/*postman_environment.json")
docker run -v $PWD:/etc/newman -t postman/newman_alpine33 -c $POSTMAN_COLLECTION -e $POSTMAN_ENVIRONMENT

# Send a test completion message to the Slack regression channel
if [ "$?" == "0" ]; then
	# Build passed
	curl -X POST --data-urlencode "payload={\"username\":\"automation-bot\",\"text\":\"Test #$TRAVIS_JOB_NUMBER *PASSED* for repo - *$TRAVIS_REPO_SLUG*\",\"attachments\":[{\"title\":\":Click here to view the results in Travis CI\",\"title_link\":\"https://travis-ci.org/$TRAVIS_REPO_SLUG/jobs/$TRAVIS_JOB_ID\",\"color\":\"good\"}]}" $SLACK_URL;
else
	# Build failed
	curl -X POST --data-urlencode "payload={\"username\":\"automation-bot\",\"text\":\"Test #$TRAVIS_JOB_NUMBER *FAILED* for repo - *$TRAVIS_REPO_SLUG*\",\"attachments\":[{\"title\":\"Click here to view the results in Travis CI\",\"title_link\":\"https://travis-ci.org/$TRAVIS_REPO_SLUG/jobs/$TRAVIS_JOB_ID\",\"color\":\"danger\"}]}" $SLACK_URL;
fi
