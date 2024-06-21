#!/bin/bash

set -e

NETWORK_NAME="stack"
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    curl -fsSL https://get.docker.com | bash -
else
    echo "Docker is already installed."
fi

# Check Docker version
docker --version

# Check docker-compose version
docker compose version

# Check if the Docker network exists
# if docker network ls --format '{{.Name}}' | grep -wq "$NETWORK_NAME"; then
#     echo "Docker network '$NETWORK_NAME' already exists."
# else
#     # Create the Docker network
#     echo "Docker network '$NETWORK_NAME' does not exist. Creating network..."
#     docker network create "$NETWORK_NAME"
    
#     # Check if the network creation was successful
#     if [ $? -eq 0 ]; then
#         echo "Docker network '$NETWORK_NAME' created successfully."
#     else
#         echo "Failed to create Docker network '$NETWORK_NAME'."
#         exit 1
#     fi
# fi


cd calcom/nginx-proxy

echo "Stopping and removing existing docker-compose containers..."
docker compose down || true  # Continue on error (if no containers are running)

echo "Starting docker-compose..."
docker compose up -d