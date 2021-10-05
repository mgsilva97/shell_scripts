#!/bin/bash

TIME_IN_SECONDS=60
REQUESTS=100000

while true; do
        /usr/bin/hey -n $REQUESTS http://your-url-here
        sleep $TIME_IN_SECONDS
        continue
    done
