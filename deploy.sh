#!/bin/bash

echo "🚀 Building and Deploying Eureka Service..."

# Build the Docker image
echo "📦 Building Docker image..."
docker build -t eureka-service:latest .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully!"
    
    # Stop and remove existing container if running
    echo "🛑 Stopping existing container..."
    docker stop eureka-service 2>/dev/null || true
    docker rm eureka-service 2>/dev/null || true
    
    # Create network if it doesn't exist
    echo "🌐 Creating network if needed..."
    docker network create microservice-network 2>/dev/null || true
    
    # Run the new container
    echo "🚀 Starting Eureka Service..."
    docker run -d \
        --name eureka-service \
        --network microservice-network \
        --network-alias eureka \
        -p 8761:8761 \
        -e SPRING_PROFILES_ACTIVE=prod \
        eureka-service:latest
    
    if [ $? -eq 0 ]; then
        echo "✅ Eureka Service deployed successfully!"
        echo "🌐 Service available at: http://localhost:8761"
        echo "📊 Health check: http://localhost:8761/actuator/health"
        echo "📝 Container logs: docker logs -f eureka-service"
    else
        echo "❌ Failed to start container"
        exit 1
    fi
else
    echo "❌ Docker build failed!"
    exit 1
fi
