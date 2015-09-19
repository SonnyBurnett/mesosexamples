#!/bin/bash

APP=$1
IPMASTER="192.168.33.61"

if [ -f $APP".json" ]; then
   curl -X POST -H "Content-Type: application/json" $IPMASTER:8080/v2/apps -d@$APP".json"
else
   echo "No valid JSON file found"
fi

exit 0
