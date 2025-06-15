#!/bin/bash
set -e

echo "🎮 Restructuring Number Game Platform for Enterprise DevOps..."

# Backup current state
echo "📦 Creating backup..."
cp -r . ../number-game-platform-backup-$(date +%Y%m%d-%H%M%S) || true

# Create new directory structure
echo "📁 Creating enterprise directory structure..."
mkdir -p game-service
mkdir -p helm-chart/{templates,values}
mkdir -p monitoring/{grafana-dashboards,prometheus-rules}
mkdir -p scripts
mkdir -p docs/.github/workflows

# Move existing files
echo "📋 Moving existing files..."
if [ -f "application/index.html" ]; then
    mv application/index.html game-service/
    echo "✅ Moved index.html to game-service/"
fi

if [ -f "Dockerfile" ]; then
    mv Dockerfile game-service/
    echo "✅ Moved Dockerfile to game-service/"
fi

# Move Helm chart files
if [ -d "number-game-chart" ]; then
    cp -r number-game-chart/* helm-chart/
    echo "✅ Copied Helm chart files"
fi

# Move GitHub Actions
if [ -f ".github/workflows/ci-cd-pipeline.yaml" ]; then
    mv .github/workflows/ci-cd-pipeline.yaml .github/workflows/ci-cd.yaml
    echo "✅ Moved CI/CD pipeline"
fi

# Clean up old directories (optional)
echo "🧹 Cleaning up..."
rm -rf application/ number-game-chart/ k8s/ 2>/dev/null || true

echo "✅ Restructuring complete!"
echo ""
echo "Next steps:"
echo "1. Review the new structure"
echo "2. Run ./scripts/setup-local.sh"
echo "3. Update your CI/CD pipeline"
echo "4. Create the GitOps repository"
