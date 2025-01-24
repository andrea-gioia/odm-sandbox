#!/bin/bash

# Main script logic
if [ -z "$1" ]; then
  echo "Usage: $0 <mysql|postgres>"
  exit 1
fi

docker start odmp-$1-registry
docker start odmp-$1-devops
docker start odmp-$1-blueprint
docker start odmp-$1-params
docker start odmp-$1-policy
docker start odmp-$1-notification

