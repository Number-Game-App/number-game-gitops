#!/bin/bash
set -e

echo "🏗️ Building Number Game Enterprise Platform..."

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Build variables
IMAGE_NAME="dockerakilesh/number-game"
SHORT_SHA=$(git rev-parse --short HEAD)
TAG="${SHORT_SHA}"

echo -e "${YELLOW}Building image: ${IMAGE_NAME}:${TAG}${NC}"

# Build Docker image
docker build -t "${IMAGE_NAME}:${TAG}" game-service/

# Tag for local development
docker tag "${IMAGE_NAME}:${TAG}" "${IMAGE_NAME}:dev"
docker tag "${IMAGE_NAME}:${TAG}" "${IMAGE_NAME}:latest"

echo -e "${GREEN}✅ Build complete!${NC}"
echo ""
echo "Images created:"
echo "- ${IMAGE_NAME}:${TAG}"
echo "- ${IMAGE_NAME}:dev"
echo "- ${IMAGE_NAME}:latest"
echo ""
echo "Next steps:"
echo "1. Deploy with: ${YELLOW}helm install number-game ./helm-chart -f helm-chart/values/development.yaml -n number-game-dev${NC}"
echo "2. Or push to registry: ${YELLOW}docker push ${IMAGE_NAME}:${TAG}${NC}"
