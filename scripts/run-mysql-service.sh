#!/bin/bash

# Function to build and run a specific service
build_and_run() {
  local SERVICE_NAME=$1
  local PORT=$2
  local DOCKERFILE_PATH="product-plane-services/${SERVICE_NAME}-server/Dockerfile"
  local CONTAINER_NAME="odmp-mysql-${SERVICE_NAME}"
  local DB_NAME=$3

  echo "Processing service: $SERVICE_NAME"

  # Remove the existing container if it exists
  if docker ps -a --format '{{.Names}}' | grep -Eq "^$CONTAINER_NAME\$"; then
    echo "Removing existing container '$CONTAINER_NAME'..."
    docker rm -f "$CONTAINER_NAME"
  else
    echo "No existing container '$CONTAINER_NAME' found."
  fi

  echo "Creating database ODMREGISTRY..."
  echo "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
  docker exec -it odmp-mysql mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

  docker build -t "odmp-mysql-$SERVICE_NAME" . -f "$DOCKERFILE_PATH" \
   --build-arg DATABASE_URL=jdbc:mysql://odmp-mysql:3306/$DB_NAME \
   --build-arg DATABASE_USERNAME=root \
   --build-arg DATABASE_PASSWORD=root \
   --build-arg FLYWAY_SCRIPTS_DIR=mysql

  # Run the Docker container
  docker run --name "$CONTAINER_NAME" -d --network odmp-network -p "$PORT:$PORT" "odmp-mysql-$SERVICE_NAME"

  # Output the connection URL
  echo "Connect here to test the $SERVICE_NAME container [http://localhost:$PORT/api/v1/pp/$SERVICE_NAME/swagger-ui/index.html]"
}

# Main script logic
if [ -z "$1" ]; then
  echo "Usage: $0 <registry|devops|blueprint|params|policy|notification|all>"
  exit 1
fi

# Navigate to the odm-platform directory
cd ../../odm-platform/ || { echo "Directory odm-platform not found."; exit 1; }

# Create the network only if it does not exist
if ! docker network inspect odmp-network >/dev/null 2>&1; then
    echo "Creating network 'odmp-network'..."
    docker network create odmp-network
else
    echo "Network 'odmp-network' already exists."
fi

case "$1" in
  registry)
    build_and_run "registry" 8001 "ODMREGISTRY"
    ;;
  devops)
    build_and_run "devops" 8002 "ODMDEVOPS"
    ;;
  blueprint)
    build_and_run "blueprint" 8003 "ODMBLUEPRINT"
    ;;
  params)
    build_and_run "params" 8004 "ODMPARAMS"
    ;;
  policy)
    build_and_run "policy" 8005 "ODMPOLICY"
    ;;
  notification)
    build_and_run "notification" 8006 "ODMNOTIFICATIONY"
    ;;
  all)
    build_and_run "registry" 8001 "ODMREGISTRY"
    build_and_run "devops" 8002 "ODMDEVOPS"
    build_and_run "blueprint" 8003 "ODMBLUEPRINT"
    build_and_run "params" 8004 "ODMPARAMS"
    build_and_run "policy" 8005 "ODMPOLICY"
    build_and_run "notification" 8006 "ODMNOTIFICATIONY"
    ;;
  *)
    echo "Invalid parameter: $1. Use 'registry', 'devops', 'blueprint', 'params',  'policy', 'notification', or 'all'."
    exit 1
    ;;
esac
