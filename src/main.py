#!/usr/bin/env python3
"""
Python application demonstrating environment variable usage with direnv.

This application reads configuration from environment variables that are
injected externally, following production best practices.

Environment Variables:
    APP_NAME: Application name (required)
    APP_ENV: Environment (dev/staging/prod, default: dev)
    APP_DEBUG: Debug mode (true/false, default: false)
    APP_PORT: Application port (default: 8000)
    DATABASE_URL: Database connection string (optional)
    API_KEY: External API key (optional, sensitive)

Setup:
    1. Install direnv: brew install direnv (macOS)
    2. Add to shell: eval "$(direnv hook zsh)" in ~/.zshrc
    3. Copy template: cp .env.example .env (at project root)
    4. Edit configuration: nano .env (at project root)
    5. Run: direnv allow (at project root)
    6. Environment variables are automatically loaded!

Environment Variable Loading Methods:
    - Terminal execution: Uses direnv to auto-load .env when entering directory
    - VS Code debugging: Uses launch.json "envFile" setting to load .env
    - Both methods load the same .env file for consistent configuration

File usage:
    .env - Single file for all local development configuration (at project root)
"""

import os
import sys
from typing import Optional


def get_env(key: str, default: Optional[str] = None, required: bool = False) -> str:
    """
    Get environment variable with optional default and required validation.
    
    Args:
        key: Environment variable name
        default: Default value if not set
        required: Raise error if not set and no default
        
    Returns:
        Environment variable value
        
    Raises:
        ValueError: If required variable is not set
    """
    value = os.getenv(key, default)
    
    if required and value is None:
        raise ValueError(
            f"Required environment variable '{key}' is not set.\n"
            f"Please ensure it's defined in your .env file or exported in your shell."
        )
    
    return value


def get_bool_env(key: str, default: bool = False) -> bool:
    """
    Get boolean environment variable.
    
    Accepts: true, yes, 1, on (case-insensitive) as True
    Everything else is False
    """
    value = os.getenv(key, str(default)).lower()
    return value in ('true', 'yes', '1', 'on')


def get_int_env(key: str, default: int) -> int:
    """
    Get integer environment variable with fallback.
    """
    try:
        return int(os.getenv(key, str(default)))
    except ValueError:
        print(f"Warning: Invalid integer for {key}, using default: {default}")
        return default


def print_config():
    """
    Display current configuration loaded from environment variables.
    """
    print("\n" + "="*60)
    print("🔧 Application Configuration")
    print("="*60)
    
    # Required variables
    try:
        app_name = get_env('APP_NAME', required=True)
        print(f"📦 Application:  {app_name}")
    except ValueError as e:
        print(f"❌ Error: {e}")
        sys.exit(1)
    
    # Optional variables with defaults
    app_env = get_env('APP_ENV', 'dev')
    app_debug = get_bool_env('APP_DEBUG', False)
    app_port = get_int_env('APP_PORT', 8000)
    
    print(f"🌍 Environment:   {app_env}")
    print(f"🐛 Debug Mode:    {app_debug}")
    print(f"🔌 Port:          {app_port}")
    
    # Optional sensitive variables (mask values)
    database_url = get_env('DATABASE_URL')
    if database_url:
        # Mask password in database URL for security
        masked_url = database_url
        if '@' in masked_url:
            parts = masked_url.split('@')
            if ':' in parts[0]:
                user_pass = parts[0].split(':')
                masked_url = f"{user_pass[0]}:****@{parts[1]}"
        print(f"� Database:      {masked_url}")
    else:
        print(f"💾 Database:      (not configured)")
    
    api_key = get_env('API_KEY')
    if api_key:
        # Mask API key for security
        masked_key = f"{api_key[:4]}...{api_key[-4:]}" if len(api_key) > 8 else "****"
        print(f"🔑 API Key:       {masked_key}")
    else:
        print(f"🔑 API Key:       (not configured)")
    
    print("="*60 + "\n")


def main():
    """
    Main application entry point.
    """
    print("\n🐍 Python Application with direnv")
    print("📝 All configuration loaded from environment variables\n")
    
    # Display loaded configuration
    print_config()
    
    # Application logic based on environment
    app_env = get_env('APP_ENV', 'dev')
    app_debug = get_bool_env('APP_DEBUG', False)
    
    if app_debug:
        print("⚠️  DEBUG MODE ENABLED - Verbose logging active")
        print(f"   All environment variables: {dict(os.environ)}\n")
    
    print(f"✅ Application running in '{app_env}' environment")
    print("🚀 Ready to process requests!\n")
    
    # Example: Environment-specific behavior
    if app_env == 'prod':
        print("🔒 Production mode: Enhanced security enabled")
    elif app_env == 'dev':
        print("🛠️  Development mode: Hot reload enabled")
    else:
        print(f"📊 {app_env.title()} mode active")
    
    print("\n💡 Tip: Edit .env file directly for all local configuration changes!")
    print("")


if __name__ == "__main__":
    main()
