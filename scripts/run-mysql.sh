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
if docker ps -a --format '{{.Names}}' | grep -Eq "^odmp-mysql\$"; then
  echo "Removing existing container 'odmp-mysql-db'..."
  docker rm -f odmp-mysql
else
  echo "No existing container 'odmp-mysql' found."
fi

# Run the mysqlQL container
echo "Starting new container 'odmp-mysql'..."
docker run --name odmp-mysql -d --network odmp-network -p 3306:3306  \
   -e MYSQL_ROOT_PASSWORD=root \
   mysql:8