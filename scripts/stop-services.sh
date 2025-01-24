#!/bin/bash

# Main script logic
if [ -z "$1" ]; then
  echo "Usage: $0 <mysql|postgres>"
  exit 1
fi

docker stop odmp-$1-registry
docker stop odmp-$1-devops
docker stop odmp-$1-blueprint
docker stop odmp-$1-params
docker stop odmp-$1-policy
docker stop odmp-$1-notification

