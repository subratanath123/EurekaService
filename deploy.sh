#!/bin/bash
set -euo pipefail

# Previous deploys used this container name and may still hold port 8761.
docker rm -f eureka-service-prod >/dev/null 2>&1 || true

docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d
docker image prune -f > /dev/null || true
