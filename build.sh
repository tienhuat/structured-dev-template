#!/bin/bash

# Build script for Docker Compose multi-container architecture
# Usage: ./build.sh [base|dev|prod|all]

set -e

echo "🏗️  Python Multi-Container Build Script"
echo "======================================"
echo ""

# Function to build base image
build_base() {
    echo "📦 Building base image (python-base service)..."
    docker compose -f docker-compose.yml build python-base
    echo "✅ Base image built successfully"
    echo ""
}

# Function to build development images
build_dev() {
    echo "🛠️  Building development environment..."
    echo "   - Building python-app with Dockerfile.dev"
    echo "   - Building dev-container"
    docker compose -f docker-compose.yml -f docker-compose.dev.yml build
    echo "✅ Development images built successfully"
    echo ""
}

# Function to build production images
build_prod() {
    echo "🚀 Building production environment..."
    echo "   - Building python-app with Dockerfile.prod"
    docker compose -f docker-compose.yml -f docker-compose.prod.yml build python-app
    echo "✅ Production images built successfully"
    echo ""
}

# Parse command line argument
case "${1:-all}" in
    "base")
        build_base
        ;;
    "dev")
        build_base
        build_dev
        ;;
    "prod")
        build_base
        build_prod
        ;;
    "all")
        build_base
        build_dev
        build_prod
        ;;
    *)
        echo "❌ Usage: $0 [base|dev|prod|all]"
        echo ""
        echo "Options:"
        echo "  base - Build only the base image"
        echo "  dev  - Build base + development images"
        echo "  prod - Build base + production images"
        echo "  all  - Build everything (default)"
        exit 1
        ;;
esac

echo "🎉 Build complete!"
echo ""
echo "📋 Available images:"
docker images | head -1  # Header
docker images | grep -E "python-dev|python-app" || echo "   (No images found)"
echo ""
echo "🚀 Next steps:"
echo ""
if [[ "${1}" == "dev" ]] || [[ "${1}" == "all" ]] || [[ -z "${1}" ]]; then
    echo "🛠️  Start development environment:"
    echo "   docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d"
    echo ""
fi
if [[ "${1}" == "prod" ]] || [[ "${1}" == "all" ]] || [[ -z "${1}" ]]; then
    echo "🚀 Start production environment:"
    echo "   docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d"
    echo ""
fi
echo "📖 Or open in VS Code:"
echo "   Cmd+Shift+P → 'Dev Containers: Reopen in Container'"
echo ""