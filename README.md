

# Python Multi-Container Development Environment

A production-ready Python development environment with **Docker Compose overrides** for clean configuration management.

## 🏗️ Architecture Overview

This setup provides **multiple ways** to develop and deploy Python applications:

1. **VS Code Dev Containers** - Native VS Code integration  
2. **Remote SSH** - Manual SSH connection to container
3. **Multi-Container Stack** - Full production-like environment
4. **Docker Compose Overrides** - DRY configuration management

The architecture uses **Docker Compose overrides** where:
- `docker-compose.yml` - Contains **all shared configuration** 
- `docker-compose.dev.yml` - **Only development-specific changes**
- `docker-compose.prod.yml` - **Only production-specific changes**

---

## 🚀 Quick Start

### Prerequisites
- VS Code installed on your host machine
- Docker running (Colima on macOS or Docker Desktop)
- Python source code in `./src/` directory

### Method 1: VS Code Dev Containers (Recommended for beginners)

**Prerequisites - Start Docker First:**

⚠️ **IMPORTANT**: Docker must be running before opening the dev container!

**macOS (using Colima):**
```bash
# Start Colima (Docker runtime for macOS)
colima start

# Verify Docker is running
docker ps
# Should show "CONTAINER ID   IMAGE   ..." header (no error)
```

**macOS (using Docker Desktop):**
```bash
# Open Docker Desktop application from Applications folder
# Wait for the Docker icon in menu bar to show "Docker Desktop is running"

# Verify Docker is running
docker ps
```

**Windows/Linux:**
```bash
# Start Docker Desktop or Docker Engine
# Verify Docker is running
docker ps
```

If you see "Cannot connect to the Docker daemon" error, Docker is not running!

---

**One-click setup:**

1. **Install the Dev Containers extension**
   - Open VS Code
   - Press `Cmd+Shift+X` (or click Extensions icon in sidebar)
   - Search for: `Dev Containers`
   - Install the extension by Microsoft

2. **Open the project folder**
   - Open VS Code
   - File → Open Folder (or `Cmd+O`)
   - Navigate to and select this `dev-container` folder
   - Click "Open"

3. **Reopen in Container**
   - **Method A - Popup notification (easiest):**
     - VS Code detects `.devcontainer/devcontainer.json`
     - Blue notification appears: "Folder contains a Dev Container configuration file"
     - Click **"Reopen in Container"** button
   
   - **Method B - Command Palette:**
     - Press `Cmd+Shift+P` (macOS) or `Ctrl+Shift+P` (Windows/Linux)
     - Type: `Dev Containers: Reopen in Container`
     - Press Enter
   
   - **Method C - Bottom-left corner:**
     - Click the green/blue icon in bottom-left corner `><`
     - Select "Reopen in Container" from the menu

4. **Wait for container to build** (first time only)
   - VS Code shows progress: "Starting Dev Container..."
   - Docker builds the image (2-5 minutes first time)
   - Subsequent opens are instant (uses cached image)

5. **You're in! Verify the setup:**
   - Terminal opens inside container automatically
   - Workspace folder shows at `/workspace`
   - Extensions install automatically
   - Bottom-left corner shows: `Dev Container: Python Multi-Container...`

**What happens behind the scenes:**
- VS Code reads `.devcontainer/devcontainer.json`
- Runs `docker compose -f docker-compose.dev.yml up`
- Mounts your code: `./` (host) → `/workspace` (container)
- Installs VS Code Server inside container
- Installs extensions listed in `devcontainer.json`
- Forwards ports 8000 and 5678 automatically
- Opens integrated terminal in container context

**Benefits:**
- ✅ Seamless VS Code integration
- ✅ Automatic extension syncing
- ✅ Zero SSH configuration
- ✅ Built-in port forwarding
- ✅ One-click setup

### Method 2: Remote SSH (Advanced/Flexible)

**Manual setup:**
1. Run the all-in-one setup script: `./setup-ssh.sh`
2. Follow the on-screen instructions to connect via SSH

**What the script does:**
- Checks/starts the dev container
- Configures your ~/.ssh/config
- Cleans old SSH keys (prevents connection errors)
- Shows step-by-step connection instructions

**Benefits:**
- ✅ Works with any remote server (not just local containers)
- ✅ More control over connection
- ✅ Can connect from multiple VS Code instances
- ✅ Standard SSH tools work
- ✅ Good for learning SSH workflows

---

## 📁 Project Structure

```
dev-container/
├── .devcontainer/
│   ├── Dockerfile              # Dev Container for VS Code (SSH, dev tools)
│   └── devcontainer.json       # VS Code Dev Containers configuration
├── .vscode/
│   └── launch.json             # VS Code debug configuration
├── src/                        # Your Python source code
│   ├── Dockerfile              # Base application image (shared)
│   ├── Dockerfile.dev          # Development variant (extends base)
│   ├── Dockerfile.prod         # Production variant (extends base)
│   ├── main.py                 # Sample Python application (Hello World)
│   └── pyproject.toml          # Modern Python project config
├── .env                        # Local development environment variables (gitignored)
├── .env.example                # Environment template (committed to git)
├── .envrc                      # direnv configuration (auto-loads .env)
├── docker-compose.yml          # Base configuration (90% shared)
├── docker-compose.dev.yml      # Development overrides (10% differences)
├── docker-compose.prod.yml     # Production overrides (10% differences)
├── build.sh                    # Build helper script
├── setup.sh                    # Complete environment setup (Docker + containers)
├── setup-ssh.sh                # SSH setup and connection helper (all-in-one)
└── README.md                   # This file
```

### Two Types of Containers

**1. Dev Container** (`.devcontainer/Dockerfile`):
- Purpose: VS Code remote development environment
- Contains: SSH server, development tools, build tools
- User: `vscode` (with sudo access)
- Usage: VS Code connects for interactive development

**2. Application Containers** (`src/Dockerfile*`):
- Purpose: Run the Python application
- Variants: Base (shared), Dev (with debugpy), Prod (optimized)
- User: `appuser` (no sudo, security)
- Usage: Direct container execution or production deployment

---

## 🔧 Container Details

**Base Image:** `python:3.13.7-slim-bookworm`

**Package Manager:** `uv` (faster alternative to pip)

**Installed Tools:**
- Python 3.13 with uv package manager
- Git, curl, wget
- SSH server (for Remote SSH method)
- Build tools (gcc, make, etc.)

**Python Environment:**
- Virtual environment at `/home/vscode/.venv`
- Auto-activated in terminals
- Project dependencies in `pyproject.toml`

**Ports (Container → Host):**
- Port `22` (container) → `2222` (host) - SSH access for Remote-SSH
- Port `8000` (container) → `8000` (host) - Application port (auto-forwarded by VS Code)
- Port `5678` (container) → `5678` (host) - Debug port (silent, used by debugpy)

**Volumes (Folder Mapping):**
- **Code Mounting**: `./src` (host) → `/workspace` (container) - Your source code
- **VS Code Server**: `vscode_server` (Docker volume) → `/home/vscode/.vscode-server` (container) - Extensions persist across rebuilds

**User:** `vscode` (non-root user with sudo access)

---

## 🎯 When to Use Each Method

### Use Dev Containers when:
- You want the easiest setup experience
- Working in a team (standardized environments)
- You prefer integrated VS Code features
- Learning containerized development

### Use Remote SSH when:
- You want to understand SSH workflows
- Need to connect to remote servers later
- Want more control over the connection
- Learning DevOps practices
- Working with existing remote infrastructure

---

## 🛠️ Development Workflow

### Starting Development

**Dev Containers:**
```bash
# Just open in VS Code and reopen in container
# Everything else is automatic!
```

**Remote SSH:**
```bash
# All-in-one setup (checks container, configures SSH, shows instructions)
./setup-ssh.sh

# Then connect via SSH (follow on-screen instructions)
# Press Cmd+Shift+P → 'Remote-SSH: Connect to Host...' → 'dev-container'
```

## 🔐 Environment Variables with direnv

This project uses **direnv** for environment variable management, following production best practices where configuration is injected externally rather than hardcoded.

### Environment Variable Loading Methods

There are **two ways** environment variables are loaded, depending on how you run your application:

#### 1. **Terminal Execution** (using direnv)
When you run Python from the terminal:
```bash
cd /workspace  # or any subdirectory
python main.py  # direnv auto-loads .env variables
```
- **How it works**: direnv automatically loads `.env` when entering the directory
- **Requirements**: direnv installed and configured (see setup below)
- **Benefit**: Works across all terminal sessions and subdirectories

#### 2. **VS Code Debugging** (using launch.json)
When you debug/run from VS Code (F5 or Run → Start Debugging):
```json
// .vscode/launch.json
"envFile": "${workspaceFolder}/.env"
```
- **How it works**: VS Code loads `.env` automatically during debug sessions
- **Requirements**: No additional setup needed
- **Benefit**: Works even without direnv installed

### What is direnv?

direnv automatically loads environment variables when you enter a directory and unloads them when you leave. This ensures:
- ✅ No hardcoded configuration in code
- ✅ Production-like environment management
- ✅ Secure handling of secrets (gitignored files)
- ✅ Simple single-file configuration
- ✅ Consistent environment across terminal and VS Code

### Setup direnv (One-Time)

**macOS:**
```bash
# Install direnv
brew install direnv

# Add to shell (choose one):
# For Zsh (default on macOS):
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc && source ~/.zshrc

# For Bash:
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc && source ~/.bashrc
```

**Ubuntu/Debian:**
```bash
sudo apt install direnv
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc && source ~/.bashrc
```

**Verification:**
```bash
direnv version  # Should show version number
```

### File Structure

Environment files follow a template-based pattern similar to Docker Compose:

```
.env.example          # ✅ Committed - Template with all variables documented (at project root) 
.env                  # ❌ Gitignored - Your local development config (at project root)
.envrc                # ✅ Committed - direnv configuration (at project root)
```

**Local Development Workflow:**
1. **Initial Setup:** `cp .env.example .env` (create your working copy)
2. **Customize:** Edit `.env` for all your local development configuration

**Production Environments (UAT/Staging/Production):**
- Environment variables are set by CI/CD pipelines, not .env files
- Use secure deployment methods: GitHub Actions secrets, Kubernetes ConfigMaps, cloud platform settings
- See `.env.example` file for detailed production deployment guide

### Usage

```bash
# Setup (at project root)
cp .env.example .env    # Copy template
nano .env               # Edit configuration
direnv allow            # Enable auto-loading for terminal usage

# Method 1: Terminal execution (uses direnv)
cd src/                 # direnv auto-loads .env from project root
python main.py          # Run with environment variables loaded

# Method 2: VS Code debugging (uses launch.json)
# Press F5 or Run → Start Debugging
# VS Code automatically loads .env via "envFile" setting
```

### Security Best Practices

✅ **DO:**
- Commit `.env.example` as template (no secrets!)
- Copy `.env.example` to `.env` for local development
- Keep API keys and sensitive data in `.env` (gitignored)
- Use different configurations per environment
- Follow production deployment guide in `.env.example`

❌ **DON'T:**
- Never commit `.env` (contains your local configuration!)
- Never put secrets in `.env.example` (it's a template!)
- Never hardcode credentials in code
- Never use `.env` files on production servers

**Summary:**
- **Template** (committed): `.env.example`
- **Local Configuration** (gitignored): `.env`
- **Production**: Environment variables via CI/CD (see `.env.example` guide)



---

### Running Python Code

Once connected (either method):
```bash
# In VS Code terminal
cd /workspace
python main.py

# Add new dependencies (uv is 10-100x faster than pip)
uv add package-name

# Install production dependencies only
uv pip install -e .

# Install production + development dependencies
uv pip install -e ".[dev]"
# The ".[dev]" tells uv to also install optional dev dependencies
# (black, flake8, pytest, mypy, etc.)
```
```

### Running Python Code

Once connected (either method):
```bash
# In VS Code terminal
cd /workspace
python main.py

# Add new dependencies (uv is 10-100x faster than pip)
uv add package-name

# Install production dependencies only
uv pip install -e .

# Install production + development dependencies
uv pip install -e ".[dev]"
# The ".[dev]" tells uv to also install optional dev dependencies
# (black, flake8, pytest, mypy, etc.)
```

## 📦 Docker Compose Overrides (Advanced)

This project uses **Docker Compose overrides** for clean configuration management:

### File Structure (90/10 Split)
```
docker-compose.yml      # 🏗️  Base configuration (90% - all shared settings)
docker-compose.dev.yml  # 🛠️  Development overrides (10% - only differences)
docker-compose.prod.yml # 🚀  Production overrides (10% - only differences)
```

**Key Concept**: Override files don't replace the base, they **merge** with it.
Docker Compose combines base + override to create the final configuration.

### Usage Patterns

```bash
# 🛠️ Development (base + dev overrides)
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# 🚀 Production (base + prod overrides)  
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 🧪 Test configuration (see what gets merged)
docker compose -f docker-compose.yml -f docker-compose.dev.yml config
```

### Quick Start Commands

```bash
# Build containers first
./build.sh dev   # For development
./build.sh prod  # For production  

# Development environment
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Production environment  
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Override Benefits
- ✅ **DRY Principle** - Shared configuration in base file
- ✅ **Minimal Overrides** - Only environment-specific differences  
- ✅ **Easy Maintenance** - Single source of truth for common settings
- ✅ **Clear Separation** - Dev vs prod differences are obvious
- ✅ **Flexible Deployment** - Can combine any base + override files

### Architecture

**Base File (Comprehensive):**
- All services (python-app, dev-container)
- Common environment variables
- Shared networks and volumes  
- Default ports and dependencies

**Dev Override (Minimal):**
- Development dockerfile (Dockerfile.dev)
- Debug ports (5678)
- Code volume mounting
- Insecure credentials

**Prod Override (Minimal):**
- Production dockerfile (Dockerfile.prod)
- Resource limits and health checks  
- Secure environment variables

### Stopping the Environment

```bash
# Development
docker compose -f docker-compose.yml -f docker-compose.dev.yml down

# Production  
docker compose -f docker-compose.yml -f docker-compose.prod.yml down

# Remove everything (including volumes)
docker compose -f docker-compose.yml -f docker-compose.dev.yml down -v
```

---

## 🔍 Troubleshooting

### Dev Containers Issues

**"Command failed" when reopening in container:**

This is usually caused by Docker Compose configuration issues. Try these steps:

1. **Check Docker is running:**
   ```bash
   docker ps
   # Should show table header, not an error
   ```

2. **BUILD THE BASE IMAGE FIRST (Most Common Issue):**
   ```bash
   # The base image must be built before starting containers
   # This is the #1 reason for "Command failed" errors!
   
   docker compose -f docker-compose.yml build python-base
   
   # Then build the dev container
   docker compose -f docker-compose.yml -f docker-compose.dev.yml build
   
   # Now try starting the containers
   docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
   ```
   
   **Why this happens:**
   - `docker-compose.dev.yml` references `python-dev-base:latest` image
   - This image doesn't exist until you build it
   - VS Code doesn't automatically build dependencies
   
   **Alternative - Use the build script:**
   ```bash
   ./build.sh dev
   # This builds everything in the correct order
   ```

3. **Fix "docker-buildx" error (macOS Colima users):**
   ```bash
   # If you see: "fork/exec docker-buildx: no such file or directory"
   
   # Install Docker Buildx plugin
   mkdir -p ~/.docker/cli-plugins
   
   # Download buildx for macOS (ARM64/M1/M2)
   curl -L https://github.com/docker/buildx/releases/download/v0.12.0/buildx-v0.12.0.darwin-arm64 \
     -o ~/.docker/cli-plugins/docker-buildx
   
   # For Intel Macs, use:
   # curl -L https://github.com/docker/buildx/releases/download/v0.12.0/buildx-v0.12.0.darwin-amd64 \
   #   -o ~/.docker/cli-plugins/docker-buildx
   
   # Make it executable
   chmod +x ~/.docker/cli-plugins/docker-buildx
   
   # Verify installation
   docker buildx version
   ```

4. **Verify the docker-compose file path:**
   ```bash
   # In the devcontainer.json, it references:
   # "dockerComposeFile": "../docker-compose.dev.yml"
   
   # Make sure docker-compose.dev.yml exists in the parent directory
   ls -la docker-compose.dev.yml
   ```

5. **Test the docker-compose configuration manually:**
   ```bash
   # Try building and starting the container manually
   docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
   
   # Check if containers are running
   docker ps
   
   # If it works, try reopening in VS Code
   # If it fails, you'll see the actual error message
   ```

6. **Check for port conflicts:**
   ```bash
   # Port 2222 (SSH) might be in use
   lsof -i :2222
   
   # Port 8000 (app) might be in use
   lsof -i :8000
   
   # If ports are in use, either:
   # - Stop the conflicting process
   # - Change ports in docker-compose.yml
   ```

5. **View detailed VS Code logs:**
   - Press `Cmd+Shift+P` → `Dev Containers: Show Container Log`
   - Look for specific error messages
   - Common errors:
     - "no such file or directory" → Check file paths
     - "port already allocated" → Port conflict (see step 4)
     - "permission denied" → Docker permissions issue

6. **Clean rebuild (nuclear option):**
   ```bash
   # Stop and remove all containers
   docker compose -f docker-compose.yml -f docker-compose.dev.yml down -v
   
   # Remove dev container images
   docker images | grep python-dev
   docker rmi <image-id>
   
   # Try opening in VS Code again (will rebuild from scratch)
   ```

7. **Check devcontainer.json configuration:**
   ```bash
   # Verify the dockerComposeFile path is correct
   cat .devcontainer/devcontainer.json | grep dockerComposeFile
   # Should show: "dockerComposeFile": "../docker-compose.dev.yml"
   
   # Verify the service name matches docker-compose
   cat .devcontainer/devcontainer.json | grep service
   # Should show: "service": "dev-container"
   ```

**Container won't start:**
- Check Docker is running: `docker ps`
- Check Docker Compose syntax: `docker compose -f docker-compose.yml -f docker-compose.dev.yml config`

**Extensions not working:**
- Restart the container: Press `Cmd+Shift+P` → `Dev Containers: Rebuild Container`

**Code not visible:**
- Ensure you opened the correct folder (the one containing `.devcontainer/`)
- Check volume mount in docker-compose.yml: `. → /workspace`

### Remote SSH Issues

**"MitmPortForwardingDisabled" error (Remote host key has changed):**

This happens when you rebuild the Docker container - it generates a new SSH host key, but your computer still remembers the old one.

**Quick Fix:**
```bash
# Remove the old SSH key from known_hosts
ssh-keygen -R "[localhost]:2222"

# Now reconnect via VS Code Remote-SSH
# It will accept the new key automatically
```

**Why this happens:**
- Every Docker container rebuild generates a new SSH host key
- Your `~/.ssh/known_hosts` file stores the old key
- SSH thinks there's a security issue (man-in-the-middle attack)
- Removing the old key resolves the issue

**Test the connection manually:**
```bash
# Verify SSH is working
ssh -p 2222 vscode@localhost "pwd && whoami"
# Enter password: vscode
# Should show: /home/vscode and vscode
```

**Prevent this in the future (Option A - Easier, less secure):**

The new `setup-ssh.sh` script already configures this for you! It sets:
```bash
Host dev-container
  HostName localhost
  User vscode
  Port 2222
  PasswordAuthentication yes
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null  # Don't save host keys for localhost
```

If you need to reconfigure, just run:
```bash
./setup-ssh.sh  # Automatically handles SSH config and key cleanup
```

**Prevent this in the future (Option B - More secure):**

Keep strict host checking enabled, just run this command after each container rebuild:
```bash
ssh-keygen -R "[localhost]:2222"
```

**Other SSH Issues:**
- **Workspace appears empty**: Remote-SSH opens `/home/vscode` by default. You MUST open `/workspace` folder manually:
  - File → Open Folder (Cmd+O)
  - Navigate to: `/workspace`
  - Click OK
  - Your files will now appear!
- **Can't connect**: Run `./setup-ssh.sh` - it checks and starts the container automatically
- **Container not found**: Run `./setup-ssh.sh` - it will start the container for you
- **Permission denied**: Password is `vscode` (not your local user password!)
- **SSH config not found**: Run `./setup-ssh.sh` to create it
- **Port 2222 in use**: Check with `lsof -i :2222` and stop conflicting process

### Environment Variable Issues

**"Required environment variable 'APP_NAME' is not set" when debugging in VS Code:**
- ✅ **Solution**: Already configured! Your `launch.json` has `"envFile": "${workspaceFolder}/.env"`
- ❌ **Cause**: Missing `.env` file at project root
- **Fix**: Ensure `.env` file exists at `/Users/tienhuat/Repositories/structured-dev-template/.env`

**Environment variables work in terminal but not VS Code debugging:**
- **Terminal**: Uses direnv (loads `.envrc` → `.env`)
- **VS Code**: Uses launch.json (`"envFile"` setting)
- **Fix**: Both should work with current setup - check `.env` file exists

**direnv not loading variables:**
```bash
# Check direnv is installed and hooked
direnv version
echo $DIRENV_DIR  # Should show path when in project directory

# Re-allow if needed
direnv allow

# Check .env file exists
ls -la .env
```

### General Issues
- **Port conflicts**: Change ports in `docker-compose.yml`
- **Python errors**: Check `pyproject.toml` dependencies
- **Package issues**: Use `uv add package-name` instead of pip
- **Container logs**: Run `docker compose logs`
- **Dev tools missing**: Install with `uv pip install -e ".[dev]"` (note the quotes!)
- **Permission issues**: Ensure files are owned by UID/GID 1000 (matches container user)

---

## 🎓 Learning Path

1. **Start with Dev Containers** - Get familiar with containerized development
2. **Try Remote SSH** - Learn manual connection methods
3. **Experiment with both** - Understand the trade-offs
4. **Choose your preference** - Based on your workflow needs

---

## 📚 Additional Resources

- [VS Code Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [VS Code Remote SSH Documentation](https://code.visualstudio.com/docs/remote/ssh)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Python Development in VS Code](https://code.visualstudio.com/docs/python/python-tutorial)

---

**Happy Coding! 🐍✨**

