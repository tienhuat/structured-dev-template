# ==============================================================================
# BASE DOCKERFILE - COMMON DEPENDENCIES FOR ALL ENVIRONMENTS
# ==============================================================================
# This Dockerfile contains the essential runtime dependencies shared by both
# development and production environments. It creates the foundation image that
# Dockerfile.dev and Dockerfile.prod extend with environment-specific features.
#
# Purpose: Create a clean, minimal Python environment that can be extended
# by Dockerfile.dev (development) or Dockerfile.prod (production)
#
# This follows the DRY principle: Define common setup once, inherit in others
#
# Build this image first:
#   docker compose -f docker-compose.yml build python-base
#
# Then build environment-specific images that extend this base.
# ==============================================================================

# -----------------------------------------------------------------------------
# BASE IMAGE
# -----------------------------------------------------------------------------
# Python 3.13 slim variant (Debian Bookworm-based)
# 'slim' variant includes:
# - Python 3.13 runtime (~150MB)
# - Essential system libraries
# - Basic shell utilities
# Excludes:
# - Development headers (gcc, make, etc.)
# - Documentation
# - Optional packages
FROM python:3.13.7-slim-bookworm

# -----------------------------------------------------------------------------
# WORKING DIRECTORY
# -----------------------------------------------------------------------------
# Set the working directory inside the container
WORKDIR /app

# Container Directory: /app
#                      (Inside container - where application code lives)
#
# All subsequent commands (COPY, RUN, CMD) will execute relative to /app
# This becomes the current directory when the container starts

# -----------------------------------------------------------------------------
# SYSTEM DEPENDENCIES
# -----------------------------------------------------------------------------
# Install minimal system packages required for Python package installation
RUN apt-get update && apt-get install -y \
    # curl: HTTP client for downloading uv installer script
    curl \
    # Clean up apt cache to reduce image size (important for Docker layers)
    && rm -rf /var/lib/apt/lists/*

# Why minimal dependencies?
# - Smaller image size = faster pulls and deployments
# - Fewer packages = smaller attack surface
# - Only install what's needed for runtime (not build tools)

# -----------------------------------------------------------------------------
# UV PACKAGE MANAGER
# -----------------------------------------------------------------------------
# Install uv - modern, fast Python package installer (written in Rust)
# Performance: 10-100x faster than pip for dependency resolution

# Why uv instead of pip?
# - Faster: Parallel downloads and installation
# - Better: Clear error messages and conflict resolution
# - Compatible: Works with pip, requirements.txt, pyproject.toml
# - Modern: Built with Rust for performance and reliability

# Install uv (installs to /root/.local/bin by default)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv to system PATH for all subsequent layers and runtime
# uv installs to /root/.local/bin (not /root/.cargo/bin)
ENV PATH="/root/.local/bin:$PATH"

# -----------------------------------------------------------------------------
# PROJECT CONFIGURATION
# -----------------------------------------------------------------------------
# Copy pyproject.toml first (before copying source code)
# This leverages Docker's layer caching for faster rebuilds
COPY pyproject.toml ./

# Docker Layer Caching Strategy:
# 1. Copy pyproject.toml (changes infrequently)
# 2. Install dependencies (expensive operation)
# 3. Copy source code (changes frequently)
#
# Result: Source code changes don't trigger dependency reinstallation
# This can save minutes on each rebuild during development

# -----------------------------------------------------------------------------
# INSTALL PYTHON DEPENDENCIES
# -----------------------------------------------------------------------------
# Install project dependencies defined in pyproject.toml
RUN uv pip install --system .

# Installation flags:
# --system: Install packages globally (skip virtual environment)
#
# Why --system flag?
# - Containers already provide isolation (like a virtual environment)
# - No need for venv inside a container
# - Simplifies paths and reduces overhead
# - Common practice for containerized Python applications
#
# The "." tells uv to install from current directory (pyproject.toml)

# -----------------------------------------------------------------------------
# COPY APPLICATION CODE
# -----------------------------------------------------------------------------
# Copy all source code into the container
COPY . .

# FOLDER MAPPING FOR BUILD:
# Host Directory:      /path/to/your/project/src
#                      (Build context - where docker compose runs from)
# Container Directory: /app
#                      (Inside container - where code is copied to)
# Copy Command:        COPY . .  (means "copy everything from build context to /app")
#
# This is done AFTER dependency installation for better layer caching
#
# RUNTIME FOLDER MAPPING (Development only):
# When running with docker-compose.dev.yml:
#   Host Directory:      ./src (on your machine)
#   Container Directory: /app (inside container)
#   Mapping:             ./src:/app:cached
#
# What this means:
# - BUILD TIME: Code is copied INTO the image (immutable)
# - DEVELOPMENT: Code is mounted FROM host (live changes)
# - PRODUCTION: No mounting (uses copied code from build)

# -----------------------------------------------------------------------------
# SECURITY: NON-ROOT USER
# -----------------------------------------------------------------------------
# Create a non-root user to run the application (security best practice)
RUN groupadd --gid 1000 appuser \
    # Create user with home directory (-m flag)
    && useradd --uid 1000 --gid 1000 -m appuser \
    # Transfer ownership of /app to appuser
    && chown -R appuser:appuser /app

# Why non-root user?
# - Security: Limits damage if container is compromised
# - Principle of least privilege: Application doesn't need root access
# - Compliance: Many security standards require non-root containers
#
# Why UID/GID 1000?
# - Standard first user ID on Linux systems
# - Matches typical developer machine UIDs
# - Simplifies file permissions when mounting volumes

# -----------------------------------------------------------------------------
# SWITCH TO NON-ROOT USER
# -----------------------------------------------------------------------------
# Switch from root to appuser for all subsequent operations
# All RUN, CMD, and ENTRYPOINT commands will execute as appuser
USER appuser

# -----------------------------------------------------------------------------
# NETWORK PORTS
# -----------------------------------------------------------------------------
# Document which port the application listens on
EXPOSE 8000

# Important: EXPOSE is documentation only!
# It does NOT:
# - Publish the port to the host
# - Open any ports on the host
# - Configure port forwarding
#
# Actual port publishing happens via:
# - docker-compose.yml: ports: ["8000:8000"]
# - docker run: docker run -p 8000:8000 <image>
#
# EXPOSE helps:
# - Document intent (which ports the app uses)
# - Tools like docker-compose can auto-detect ports
# - Other developers understand port requirements

# -----------------------------------------------------------------------------
# DEFAULT COMMAND
# -----------------------------------------------------------------------------
# Default command executed when container starts
CMD ["python", "main.py"]

# This command can be overridden by:
# - Dockerfile.dev: Uses tail -f /dev/null (keeps container alive)
# - Dockerfile.prod: Same command (runs application)
# - docker-compose.yml: Can specify different command per service
# - docker run: docker run <image> python other_script.py
#
# CMD vs ENTRYPOINT:
# - CMD: Easy to override completely
# - ENTRYPOINT: Defines fixed executable, CMD becomes arguments
# - We use CMD for flexibility in different environments

# ==============================================================================
# DOCKERFILE INHERITANCE PATTERN:
# ==============================================================================
# This base Dockerfile is extended by:
# 
# 1. Dockerfile.dev:
#    FROM python-dev-base:latest  (this image)
#    - Adds debugpy for remote debugging
#    - Adds development tools (pytest, black, flake8)
#    - Keeps container running for interactive development
#
# 2. Dockerfile.prod:
#    FROM python-dev-base:latest  (this image)
#    - Adds health checks
#    - No debug tools (security)
#    - Optimized for production performance
#
# This ensures both environments use the exact same base runtime!
# ==============================================================================