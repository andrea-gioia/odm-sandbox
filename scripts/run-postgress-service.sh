#!/bin/bash

# Function to build and run a specific service
build_and_run() {
  local SERVICE_NAME=$1
  local PORT=$2
  local DOCKERFILE_PATH="product-plane-services/${SERVICE_NAME}-server/Dockerfile"
  local CONTAINER_NAME="odmp-postgres-${SERVICE_NAME}"

  echo "Processing service: $SERVICE_NAME"

  # Remove the existing container if it exists
  if docker ps -a --format '{{.Names}}' | grep -Eq "^$CONTAINER_NAME\$"; then
    echo "Removing existing container '$CONTAINER_NAME'..."
    docker rm -f "$CONTAINER_NAME"
  else
    echo "No existing container '$CONTAINER_NAME' found."
  fi

  # Build the Docker image
  docker build -t "odmp-postgres-$SERVICE_NAME" . -f "$DOCKERFILE_PATH" \
    --build-arg DATABASE_URL=jdbc:postgresql://odmp-postgres:5432/odmpdb \
    --build-arg DATABASE_USERNAME=postgres \
    --build-arg DATABASE_PASSWORD=postgres \
    --build-arg FLYWAY_SCRIPTS_DIR=postgresql

  # Run the Docker container
  docker run --name "$CONTAINER_NAME" -d --network odmp-network -p "$PORT:$PORT" "odmp-postgres-$SERVICE_NAME"

  # Output the connection URL
  echo "Connect here to test the $SERVICE_NAME container [http://localhost:$PORT/api/v1/pp/$SERVICE_NAME/swagger-ui/index.html]"
}

# Main script logic
if [ -z "$1" ]; then
  echo "Usage: $0 <registry|notification|all>"
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
    build_and_run "registry" 8001
    ;;
  devops)
    build_and_run "devops" 8002
    ;;
  blueprint)
    build_and_run "blueprint" 8003
    ;;
  params)
    build_and_run "params" 8004
    ;;
  policy)
    build_and_run "policy" 8005
    ;;
  notification)
    build_and_run "notification" 8006
    ;;
  all)
    build_and_run "registry" 8001
    build_and_run "devops" 8002
    build_and_run "blueprint" 8003
    build_and_run "params" 8004
    build_and_run "policy" 8005
    build_and_run "notification" 8006
    ;;
  *)
    echo "Invalid parameter: $1. Use 'registry', 'devops', 'blueprint', 'params',  'policy', 'notification', or 'all'."
    exit 1
    ;;
esac
