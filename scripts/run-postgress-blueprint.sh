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
if docker ps -a --format '{{.Names}}' | grep -Eq "^odmp-postgres-blueprint\$"; then
  echo "Removing existing container 'odmp-postgres-blueprint'..."
  docker rm -f odmp-postgres-blueprint
else
  echo "No existing container 'odmp-postgres-blueprint' found."
fi

docker build -t odmp-postgres-blueprint . -f product-plane-services/blueprint-server/Dockerfile \
   --build-arg DATABASE_URL=jdbc:postgresql://odmp-postgres:5432/odmpdb \
   --build-arg DATABASE_USERNAME=postgres \
   --build-arg DATABASE_PASSWORD=postgres \
   --build-arg FLYWAY_SCRIPTS_DIR=postgresql


docker run --name odmp-postgres-blueprint  -d --network odmp-network -p 8003:8003 odmp-postgres-blueprint

echo "Connect here to test the container [http://localhost:8003/api/v1/pp/blueprint/swagger-ui/index.html]"