#!/bin/bash

# Navigate to the odm-platform directory
cd ../../odm-platform/


# Create the network only if it does not exist
if ! docker network inspect odmp-network >/dev/null 2>&1; then
  echo "Creating network 'odmp-network'..."
  docker network create odmp-network
else
  echo "Network 'odmp-network' already exists."
fi

# Remove the existing container if it exists
if docker ps -a --format '{{.Names}}' | grep -Eq "^odmp-postgres-params\$"; then
  echo "Removing existing container 'odmp-postgres-params'..."
  docker rm -f odmp-postgres-params
else
  echo "No existing container 'odmp-postgres-params' found."
fi

docker build -t odmp-postgres-params . -f product-plane-services/params-server/Dockerfile \
   --build-arg DATABASE_URL=jdbc:postgresql://odmp-postgres:5432/odmpdb \
   --build-arg DATABASE_USERNAME=postgres \
   --build-arg DATABASE_PASSWORD=postgres \
   --build-arg FLYWAY_SCRIPTS_DIR=postgresql


docker run --name odmp-postgres-params  -d --network odmp-network -p 8003:8003 odmp-postgres-params

echo "Connect here to test the container [http://localhost:8003/api/v1/pp/params/swagger-ui/index.html]"