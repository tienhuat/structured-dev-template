# ==============================================================================
# VS CODE DEV CONTAINER DOCKERFILE
# ==============================================================================
# This Dockerfile creates a development environment specifically for VS Code's
# Dev Containers extension. It provides a complete development workspace with:
# - Python 3.13 runtime
# - SSH server for VS Code Remote-SSH connection
# - Development tools (git, curl, wget, build tools)
# - uv package manager for fast Python package installation
# - Non-root user (vscode) for security
# - Virtual environment pre-configured
#
# This container is separate from the application container (src/Dockerfile)
# and is used exclusively for VS Code remote development.
# ==============================================================================

# -----------------------------------------------------------------------------
# BASE IMAGE
# -----------------------------------------------------------------------------
# Python 3.13 slim variant (Debian Bookworm-based)
# Same version as application containers for consistency
FROM python:3.13.7-slim-bookworm

# -----------------------------------------------------------------------------
# SYSTEM DEPENDENCIES
# -----------------------------------------------------------------------------
# Install tools needed for development and VS Code integration
RUN apt-get update && apt-get install -y \
    # git: Version control (required for most development workflows)
    git \
    # curl: Download files (used to install uv)
    curl \
    # wget: Alternative download tool (useful for various tasks)
    wget \
    # sudo: Allow vscode user to run privileged commands
    sudo \
    # openssh-server: SSH daemon for VS Code Remote-SSH connection
    openssh-server \
    # build-essential: C/C++ compilers (needed for some Python packages)
    build-essential \
    # procps: Process utilities (ps, top, etc.)
    procps \
    # Clean up apt cache to reduce image size
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# INSTALL DIRENV
# -----------------------------------------------------------------------------
# Install direnv from official binary releases (more reliable than apt)
# direnv automatically loads environment variables from .envrc files
RUN curl -sfL https://direnv.net/install.sh | bash

# -----------------------------------------------------------------------------
# INSTALL UV PACKAGE MANAGER
# -----------------------------------------------------------------------------
# Install uv to a system-wide location accessible by all users
# Default location (/root/.local/bin) is only accessible by root
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    # Copy uv from root's directory to system-wide location
    && cp /root/.local/bin/uv /usr/local/bin/uv \
    && cp /root/.local/bin/uvx /usr/local/bin/uvx \
    # Make executable by all users
    && chmod 755 /usr/local/bin/uv /usr/local/bin/uvx

# -----------------------------------------------------------------------------
# SSH SERVER CONFIGURATION
# -----------------------------------------------------------------------------
# Configure SSH daemon for secure VS Code Remote-SSH connections
RUN mkdir -p /var/run/sshd \
    # Allow password authentication (simpler for development)
    && echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
    # Disable root login (security best practice)
    && echo 'PermitRootLogin no' >> /etc/ssh/sshd_config \
    # Allow SSH key authentication (more secure than passwords)
    && echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config \
    # Disable X11 forwarding (not needed, reduces attack surface)
    && echo 'X11Forwarding no' >> /etc/ssh/sshd_config \
    # Avoid PAM loginuid warnings inside containers
    && sed -i 's@session\s\+required\s\+pam_loginuid\.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
 

# -----------------------------------------------------------------------------
# NON-ROOT USER CREATION
# -----------------------------------------------------------------------------
# Create 'vscode' user for development (security best practice)
RUN groupadd --gid 1000 vscode \
    # Create user with matching UID/GID (aligns with typical host user)
    # --uid 1000: User ID (1000 is the first non-system user on Linux/macOS)
    # --gid 1000: Group ID (matches the group created above)
    # -m: Create home directory (/home/vscode)
    # Why 1000? Most Linux/macOS systems start user IDs at 1000
    # Matching host UID/GID prevents file permission issues with mounted volumes
    && useradd --uid 1000 --gid 1000 -m vscode \
    # Configure sudo access for vscode user (convenient for development)
    # Sudoers syntax breakdown: "vscode ALL=(ALL) NOPASSWD:ALL"
    #   vscode     = Username that gets sudo privileges
    #   ALL        = Can run sudo from any host/terminal
    #   (ALL)      = Can run commands as any user (root, other users)
    #   NOPASSWD:  = Don't prompt for password when using sudo
    #   ALL        = Can run any command
    # Result: vscode can run "sudo <any-command>" without entering a password
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    # Set password for SSH login
    # Format: "username:password" | chpasswd
    # Sets password to "vscode" for user "vscode"
    # You'll use this when SSH'ing into the container
    && echo 'vscode:vscode' | chpasswd

# -----------------------------------------------------------------------------
# WORKSPACE DIRECTORY
# -----------------------------------------------------------------------------
# Create workspace directory where project files will be mounted
RUN mkdir -p /workspace && chown vscode:vscode /workspace

# FOLDER MAPPING EXPLANATION:
# Host Directory:      /path/to/your/project
#                      (Your local machine - where you clone the repo)
# Container Directory: /workspace
#                      (Inside the container - where VS Code works)
# Mapping:             . (project root) -> /workspace
#
# This is configured in devcontainer.json:
#   "workspaceFolder": "/workspace"
# And in docker-compose.yml:
#   volumes:
#     - .:/workspace:cached
#
# What this means:
# - Files you edit on your host machine appear instantly in /workspace
# - Changes in /workspace (container) sync back to your host machine
# - Both environments see the same files in real-time

# -----------------------------------------------------------------------------
# VS CODE SERVER DIRECTORIES
# -----------------------------------------------------------------------------
# Prepare directories for VS Code Server (extensions, settings, etc.)
RUN mkdir -p /home/vscode/.vscode-server \
    # Ensure vscode user owns all files in home directory
    && chown -R vscode:vscode /home/vscode \
    # Set proper permissions (rwxr-xr-x)
    && chmod -R 755 /home/vscode

# VS CODE SERVER FOLDER MAPPING:
# Host Storage:        Docker Named Volume "vscode_server"
#                      (Managed by Docker, not a visible folder on host)
# Container Directory: /home/vscode/.vscode-server
#                      (Inside container - where VS Code stores extensions)
# Mapping:             vscode_server (Docker volume) -> /home/vscode/.vscode-server
#
# This is configured in docker-compose.yml:
#   volumes:
#     - vscode_server:/home/vscode/.vscode-server
#
# What this means:
# - VS Code extensions install here (not on your host machine)
# - Extensions persist even if you delete and recreate the container
# - This volume survives container rebuilds (no need to reinstall extensions)
# - To inspect: docker volume inspect python-app-vscode-server

# -----------------------------------------------------------------------------
# SSH STARTUP SCRIPT
# -----------------------------------------------------------------------------
# Create script to start SSH server and keep container running
RUN echo '#!/bin/bash' > /start-ssh-only.sh \
    # Start SSH daemon as root (required for port 22)
    && echo 'set -e' >> /start-ssh-only.sh \
    && echo '/usr/sbin/sshd -D -e' >> /start-ssh-only.sh \
    # Log success message for debugging
    && echo 'echo "SSH server started successfully"' >> /start-ssh-only.sh \
    # Keep container alive indefinitely
    && echo 'tail -f /dev/null' >> /start-ssh-only.sh \
    # Make script executable
    && chmod +x /start-ssh-only.sh

# -----------------------------------------------------------------------------
# SWITCH TO NON-ROOT USER
# -----------------------------------------------------------------------------
# All subsequent commands run as vscode user (security best practice)
USER vscode
WORKDIR /workspace

# -----------------------------------------------------------------------------
# PYTHON VIRTUAL ENVIRONMENT
# -----------------------------------------------------------------------------
# Create virtual environment for Python packages
# uv is now available system-wide at /usr/local/bin/uv
RUN uv venv /home/vscode/.venv \
    # Auto-activate virtual environment in bash shells
    && echo 'source /home/vscode/.venv/bin/activate' >> /home/vscode/.bashrc \
    # Initialize direnv hook for automatic .envrc loading
    && echo 'eval "$(direnv hook bash)"' >> /home/vscode/.bashrc \
    # Also add to .bash_profile for login shells
    && echo 'source /home/vscode/.venv/bin/activate' >> /home/vscode/.bash_profile \
    && echo 'eval "$(direnv hook bash)"' >> /home/vscode/.bash_profile \
    # Create .config directory for direnv
    && mkdir -p /home/vscode/.config/direnv \
    # Configure direnv to load .envrc files automatically
    && echo '[whitelist]' > /home/vscode/.config/direnv/config.toml \
    && echo 'prefix = [ "/workspace" ]' >> /home/vscode/.config/direnv/config.toml \
    # Create a profile.d script for system-wide direnv initialization
    && echo '#!/bin/bash' > /home/vscode/.profile \
    && echo 'source ~/.bashrc' >> /home/vscode/.profile

# -----------------------------------------------------------------------------
# CONTAINER IDENTIFIER
# -----------------------------------------------------------------------------
# Create an identifier file to detect which container main.py is running in
USER root
RUN echo "dev-container" > /etc/container-name && chmod 644 /etc/container-name

# -----------------------------------------------------------------------------
# EXPOSE SSH PORT
# -----------------------------------------------------------------------------
# Port 22: SSH server for VS Code Remote-SSH connection
# VS Code connects to this port to provide remote development capabilities
USER root
EXPOSE 22

# -----------------------------------------------------------------------------
# CONTAINER STARTUP
# -----------------------------------------------------------------------------
# Start SSH server and keep container running
# VS Code will connect via SSH to provide full IDE experience inside container
CMD ["/start-ssh-only.sh"]

# ==============================================================================
# HOW VS CODE DEV CONTAINERS WORK:
# ==============================================================================
#
# 1. Container Startup:
#    - Docker builds this image
#    - Container starts with SSH server running
#    - Container listens on port 22 (mapped to host port 2222)
#
# 2. VS Code Connection:
#    - VS Code Dev Containers extension detects devcontainer.json
#    - Extension connects to container via SSH or Docker exec
#    - VS Code Server is installed inside container (~/.vscode-server)
#    - Extensions are installed in the container (not on host)
#
# 3. Development Workflow:
#    - Edit files in VS Code (changes sync to container via volume mount)
#    - Run commands in integrated terminal (executes inside container)
#    - Debug code with breakpoints (debugger runs in container)
#    - All tools/extensions run in container environment
#
# 4. Benefits:
#    - Consistent environment across team (no "works on my machine")
#    - Isolated from host system (clean separation)
#    - Reproducible setup (defined in code, not manual steps)
#    - Easy onboarding (clone repo, open in container, start coding)
#
# ==============================================================================
# DEV CONTAINER vs APPLICATION CONTAINER:
# ==============================================================================
#
# DEV CONTAINER (this file):
# - Purpose: VS Code remote development environment
# - Contains: SSH server, development tools, build tools
# - User: vscode (with sudo access)
# - Lifetime: Stays running for interactive development
# - Usage: VS Code connects via SSH or Docker
#
# APPLICATION CONTAINER (src/Dockerfile):
# - Purpose: Run the Python application
# - Contains: Only runtime dependencies
# - User: appuser (no sudo)
# - Lifetime: Runs application process, exits when done
# - Usage: Direct container execution or production deployment
#
# ==============================================================================
