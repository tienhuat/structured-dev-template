#!/bin/bash

# ==============================================================================
# VS CODE REMOTE-SSH SETUP AND CONNECTION HELPER
# ==============================================================================
# This script combines SSH configuration and connection instructions:
# 1. Configures ~/.ssh/config for easy connection (one-time)
# 2. Checks/starts the dev container with SSH server
# 3. Provides step-by-step connection instructions
# 4. Includes troubleshooting tips
#
# Usage: ./setup-ssh.sh
# ==============================================================================

set -e

printf "\n"
printf "🔗 VS Code Remote-SSH Setup\n"
printf "============================\n"
printf "\n"

# ------------------------------------------------------------------------------
# STEP 1: CHECK/START CONTAINER
# ------------------------------------------------------------------------------
printf "🐋 Checking if dev container is running...\n"

# Check if container exists and is running
if docker ps --format '{{.Names}}' | grep -q "python-dev-env"; then
    printf "✅ Container is running\n"
elif docker ps -a --format '{{.Names}}' | grep -q "python-dev-env"; then
    printf "⚠️  Container exists but is stopped. Starting...\n"
    docker compose -f docker-compose.yml -f docker-compose.dev.yml start dev-container
    sleep 2
    printf "✅ Container started\n"
else
    printf "❌ Container not found. Starting from scratch...\n"
    docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d dev-container
    sleep 3
    printf "✅ Container created and started\n"
fi
printf "\n"

# ------------------------------------------------------------------------------
# STEP 2: VERIFY SSH PORT
# ------------------------------------------------------------------------------
printf "🔍 Verifying SSH server is accessible...\n"
if docker ps --format '{{.Names}}\t{{.Ports}}' | grep "python-dev-env" | grep -q "2222"; then
    printf "✅ SSH server is listening on port 2222\n"
else
    printf "❌ SSH port 2222 not exposed. Check docker-compose configuration.\n"
    exit 1
fi
printf "\n"

# ------------------------------------------------------------------------------
# STEP 3: CONFIGURE SSH (ONE-TIME)
# ------------------------------------------------------------------------------
printf "🔧 Configuring SSH on your host machine...\n"

SSH_CONFIG_FILE="$HOME/.ssh/config"
CONFIG_ENTRY="
# Dev Container Configuration
Host dev-container
  HostName localhost
  User vscode
  Port 2222
  PasswordAuthentication yes
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
"

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh

# Check if config already exists
if grep -q "Host dev-container" "$SSH_CONFIG_FILE" 2>/dev/null; then
    printf "✅ SSH config already exists in ~/.ssh/config\n"
    printf "   (Skipping - entry already present)\n"
else
    printf "$CONFIG_ENTRY" >> "$SSH_CONFIG_FILE"
    printf "✅ Added SSH config to ~/.ssh/config\n"
fi
printf "\n"

# ------------------------------------------------------------------------------
# STEP 4: CLEAN OLD SSH KEYS (PREVENT MITM ERROR)
# ------------------------------------------------------------------------------
printf "🧹 Cleaning old SSH host keys (prevents connection errors)...\n"
ssh-keygen -R "[localhost]:2222" 2>/dev/null || true
printf "✅ Old SSH keys removed\n"
printf "\n"

# ------------------------------------------------------------------------------
# STEP 5: CONNECTION INSTRUCTIONS
# ------------------------------------------------------------------------------
printf "🎉 Setup Complete!\n"
printf "==================\n"
printf "\n"
printf "📋 Connection Details:\n"
printf "   Host:     localhost (or use 'dev-container')\n"
printf "   Port:     2222\n"
printf "   Username: vscode\n"
printf "   Password: vscode\n"
printf "\n"
printf "🚀 How to Connect from VS Code:\n"
printf "\n"
printf "1️⃣  Install Remote-SSH extension (if not already installed):\n"
printf "   - Open VS Code\n"
printf "   - Press Cmd+Shift+X\n"
printf "   - Search: 'Remote - SSH'\n"
printf "   - Install by Microsoft\n"
printf "\n"
printf "2️⃣  Connect to the container:\n"
printf "   - Press Cmd+Shift+P\n"
printf "   - Type: 'Remote-SSH: Connect to Host...'\n"
printf "   - Select: 'dev-container'\n"
printf "   - Enter password: vscode\n"
printf "\n"
printf "3️⃣  Open your workspace:\n"
printf "   ⚠️  IMPORTANT: Remote-SSH opens /home/vscode by default (empty!)\n"
printf "   You MUST manually open the /workspace folder:\n"
printf "   - File → Open Folder (or Cmd+O)\n"
printf "   - Type or navigate to: /workspace\n"
printf "   - Click 'OK'\n"
printf "   - Your project files will now appear!\n"
printf "\n"
printf "✨ Benefits:\n"
printf "   - Full VS Code IDE inside container\n"
printf "   - All extensions work natively\n"
printf "   - Direct file access\n"
printf "   - Integrated terminal\n"
printf "\n"
printf "🔧 Troubleshooting:\n"
printf "\n"
printf "   Connection refused:\n"
printf "   → Check container: docker ps | grep python-dev-env\n"
printf "   → Restart: docker compose -f docker-compose.yml -f docker-compose.dev.yml restart dev-container\n"
printf "\n"
printf "   'Remote host key changed' error:\n"
printf "   → Already fixed! (We cleaned old keys above)\n"
printf "   → If it happens again: ssh-keygen -R \"[localhost]:2222\"\n"
printf "\n"
printf "   Permission denied:\n"
printf "   → Verify password is: vscode (lowercase)\n"
printf "   → Not your host machine password!\n"
printf "\n"
printf "   Port 2222 already in use:\n"
printf "   → Check: lsof -i :2222\n"
printf "   → Stop conflicting process or change port in docker-compose.yml\n"
printf "\n"
printf "📝 Test SSH manually (optional):\n"
printf "   ssh vscode@dev-container\n"
printf "   # Or: ssh -p 2222 vscode@localhost\n"
printf "   # Password: vscode\n"
printf "   # Once connected, verify workspace:\n"
printf "   ls /workspace  # Should show your project files\n"
printf "\n"
printf "⚠️  COMMON MISTAKE:\n"
printf "   Remote-SSH connects you to /home/vscode (nearly empty)\n"
printf "   Your code is in /workspace (different location!)\n"
printf "   Always use: File → Open Folder → /workspace\n"
printf "\n"
printf "📖 View logs:\n"
printf "   docker compose -f docker-compose.yml -f docker-compose.dev.yml logs dev-container\n"
printf "\n"
