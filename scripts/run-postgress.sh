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
if docker ps -a --format '{{.Names}}' | grep -Eq "^odmp-postgres\$"; then
  echo "Removing existing container 'odmp-postgres'..."
  docker rm -f odmp-postgres
else
  echo "No existing container 'odmp-postgres' found."
fi

# Run the PostgreSQL container
echo "Starting new container 'odmp-postgres'..."
docker run --name odmp-postgres -d --network odmp-network -p 5432:5432 \
  -e POSTGRES_DB=odmpdb \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  postgres:11-alpine