#!/bin/bash

# ==============================================================================
# COMPLETE DEVELOPMENT ENVIRONMENT SETUP
# ==============================================================================
# This script automates the entire setup process for macOS with Colima:
# 1. Checks/installs Colima (Docker runtime for macOS)
# 2. Starts Colima if not running
# 3. Builds all Docker images (base + dev)
# 4. Starts development containers
# 5. Provides next steps for VS Code connection
#
# Usage: ./setup.sh
# ==============================================================================

set -e

printf "\n"
printf "🚀 Python Dev Container - Complete Setup\n"
printf "==========================================\n"
printf "\n"

# ------------------------------------------------------------------------------
# STEP 1: CHECK/INSTALL COLIMA
# ------------------------------------------------------------------------------
printf "📋 Checking Docker environment (Colima)...\n"
if ! command -v colima &> /dev/null; then
    printf "❌ Colima not found. Installing with Homebrew...\n"
    printf "   This will install: colima, docker, docker-compose\n"
    brew install colima docker docker-compose
    printf "✅ Colima installed successfully\n"
else
    printf "✅ Colima is already installed\n"
fi
printf "\n"

# ------------------------------------------------------------------------------
# STEP 2: START COLIMA
# ------------------------------------------------------------------------------
printf "🔄 Ensuring Colima is running...\n"
if ! colima status &> /dev/null; then
    printf "   Starting Colima with recommended configuration (this may take a few minutes)...\n"
    printf "   Configuration: 4 CPUs, 8GB RAM, 100GB disk, virtiofs mounting\n"
    colima start --cpu 4 --memory 8 --disk 100 \
      --mount-type=virtiofs \
      --dns 1.1.1.1,8.8.8.8
    printf "✅ Colima started successfully with optimized settings\n"
else
    printf "✅ Colima is already running\n"
fi
printf "\n"

# ------------------------------------------------------------------------------
# STEP 3: VERIFY DOCKER
# ------------------------------------------------------------------------------
printf "🐋 Verifying Docker accessibility...\n"
if ! docker ps &> /dev/null; then
    printf "❌ Docker not accessible. Please check Colima setup:\n"
    printf "   - Try: colima restart\n"
    printf "   - Or: colima delete && colima start\n"
    exit 1
else
    printf "✅ Docker is accessible\n"
fi
printf "\n"

# ------------------------------------------------------------------------------
# STEP 4: BUILD IMAGES
# ------------------------------------------------------------------------------
printf "🔨 Building Docker images...\n"
printf "   This uses build.sh to create base + dev images\n"
printf "\n"
if [ -f "./build.sh" ]; then
    ./build.sh dev
else
    printf "⚠️  build.sh not found. Building manually...\n"
    docker compose -f docker-compose.yml -f docker-compose.dev.yml build
fi
printf "\n"

# ------------------------------------------------------------------------------
# STEP 5: START CONTAINERS
# ------------------------------------------------------------------------------
printf "🚀 Starting development containers...\n"
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
printf "✅ Containers started successfully\n"
printf "\n"

# ------------------------------------------------------------------------------
# STEP 6: WAIT FOR READY
# ------------------------------------------------------------------------------
printf "⏳ Waiting for containers to be ready...\n"
sleep 5
printf "\n"

# ------------------------------------------------------------------------------
# STEP 7: VERIFY RUNNING
# ------------------------------------------------------------------------------
printf "🔍 Checking container status...\n"
if docker compose -f docker-compose.yml -f docker-compose.dev.yml ps | grep -q "Up"; then
    printf "✅ All containers are running!\n"
else
    printf "⚠️  Some containers may not be running. Check logs:\n"
    printf "   docker compose -f docker-compose.yml -f docker-compose.dev.yml logs\n"
fi
printf "\n"

# ------------------------------------------------------------------------------
# SUCCESS MESSAGE
# ------------------------------------------------------------------------------
printf "🎉 Setup Complete!\n"
printf "==================\n"
printf "\n"
printf "📖 Next Steps:\n"
printf "\n"
printf "1️⃣  Open in VS Code Dev Containers (RECOMMENDED):\n"
printf "   - Open VS Code in this project\n"
printf "   - Press Cmd+Shift+P\n"
printf "   - Select 'Dev Containers: Reopen in Container'\n"
printf "   - VS Code will attach to the running container\n"
printf "\n"
printf "2️⃣  Or connect via SSH (Alternative):\n"
printf "   - Run: ./setup-ssh.sh\n"
printf "   - Follow on-screen instructions to connect\n"
printf "\n"
printf "3️⃣  Or access application directly:\n"
printf "   - Visit: http://localhost:8000\n"
printf "   - Your source code: ./src/\n"
printf "\n"
printf "📝 Useful Commands:\n"
printf "   View logs:    docker compose -f docker-compose.yml -f docker-compose.dev.yml logs -f\n"
printf "   Stop:         docker compose -f docker-compose.yml -f docker-compose.dev.yml down\n"
printf "   Restart:      docker compose -f docker-compose.yml -f docker-compose.dev.yml restart\n"
printf "   Shell access: docker compose -f docker-compose.yml -f docker-compose.dev.yml exec python-app bash\n"
printf "\n"
printf "🧪 Test the setup:\n"
printf "   docker compose -f docker-compose.yml -f docker-compose.dev.yml exec python-app python main.py\n"
printf "\n"