#!/bin/bash

# Send a test started message to the Slack regression channel
curl -X POST --data-urlencode "payload={\"username\": \"automation-bot\", \"text\": \"Test #$TRAVIS_BUILD_NUMBER *STARTED* for repo: *$TRAVIS_REPO_SLUG*\"}" $SLACK_URL

# Run the postman collection
docker run -v $PWD/test/data:/etc/newman -t postman/newman_alpine33 -c HTTPBinNewmanTest.json.postman_collection -e HTTPBinNewmanTestEnv.json.postman_environment

# Send a test completion message to the Slack regression channel
if [ "$?" == "0" ]; then
	# Build passed
	curl -X POST --data-urlencode "payload={\"username\":\"automation-bot\",\"text\":\"Test #$TRAVIS_BUILD_NUMBER *PASSED* for repo - *$TRAVIS_REPO_SLUG*\",\"attachments\":[{\"title\":\":Click here to view the results in Travis CI\",\"title_link\":\"https://travis-ci.org/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID\",\"color\":\"good\",\"thumb_url\":\"$PASSED_ICON\"}]}" $SLACK_URL;
else
	# Build failed
	curl -X POST --data-urlencode "payload={\"username\":\"automation-bot\",\"text\":\"Test #$TRAVIS_BUILD_NUMBER *FAILED* for repo - *$TRAVIS_REPO_SLUG*\",\"attachments\":[{\"title\":\"Click here to view the results in Travis CI\",\"title_link\":\"https://travis-ci.org/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID\",\"color\":\"danger\",\"thumb_url\":\"$FAILED_ICON\"}]}" $SLACK_URL;
fi
