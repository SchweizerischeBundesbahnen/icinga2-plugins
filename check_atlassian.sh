#!/bin/bash

ATLASSIAN_URL="$1"

function responseTime {
  curl -o /dev/null -s -L -w "%{time_total}" "$1"
}

# Check api status
ATLASSIAN_STATE=$(curl -s -L "$1/status" 2>/dev/null)

if [ "$ATLASSIAN_STATE" != '{"state":"RUNNING"}' ]; then
  echo "Atlassian status endpoint has bad state."
  exit 2
fi

# Check response time
RESPONSE_TIME=$(responseTime "$ATLASSIAN_URL")
if [ $(echo "$RESPONSE_TIME > 0" | bc) -eq 1 ]; then
  if [ $(echo "$RESPONSE_TIME > 1" | bc) -eq 1 ]; then
    echo "Atlassian is slow (more than 1s for reaction) | response_time=${RESPONSE_TIME}s"
    exit 1
  else
    echo "Atlassian OK | response_time=${RESPONSE_TIME}s"
    exit 0
  fi
else
  echo "Atlassian Critical"
  exit 2
fi
