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
if docker ps -a --format '{{.Names}}' | grep -Eq "^odmp-mysql-registry\$"; then
  echo "Removing existing container 'odmp-mysql-registry'..."
  docker rm -f odmp-mysql-registry
else
  echo "No existing container 'odmp-mysql-registry' found."
  pwd
fi

echo "Creating database ODMREGISTRY..."
docker exec -it odmp-mysql-db mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS ODMREGISTRY;"

echo "Building image odmp-mysql-registry...."
docker build -t odmp-mysql-registry . -f product-plane-services/registry-server/Dockerfile \
   --build-arg DATABASE_URL=jdbc:mysql://odmp-mysql-db:3306/ODMREGISTRY \
   --build-arg DATABASE_USERNAME=root \
   --build-arg DATABASE_PASSWORD=root \
   --build-arg FLYWAY_SCRIPTS_DIR=mysql

echo "Running containe odmp-mysql-registry...."
docker run --name odmp-mysql-registry  -d --network odmp-network -p 8001:8001 odmp-mysql-registry

echo "Connect here to test the container [http://localhost:8001/api/v1/pp/registry/swagger-ui/index.html]"