#!/usr/bin/env python3
"""
Simple Python application to display container information and environment variables.
"""

import os


def get_container_name() -> str:
    """
    Detect which container this code is running in.
    
    Returns:
        Container name from /etc/container-name, or 'host' if not in container
    """
    try:
        with open('/etc/container-name', 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        return 'host'
    except Exception as e:
        return f'unknown ({e})'


def main():
    """
    Main application entry point.
    """
    # Display container information
    container = get_container_name()
    print("\n" + "="*60)
    print("🐳 Container Information")
    print("="*60)
    
    if container == 'dev-container':
        print(f"Container: {container} (VS Code Dev Container)")
    elif container == 'python-app':
        print(f"Container: {container} (Application Container)")
    elif container == 'host':
        print(f"Running on: Host machine (not in container)")
    else:
        print(f"Container: {container}")
    
    print("="*60 + "\n")
    
    # Print all environment variables
    print("="*60)
    print("📋 All Environment Variables")
    print("="*60)
    
    for key, value in sorted(os.environ.items()):
        print(f"{key}={value}")
    
    print("="*60 + "\n")


if __name__ == "__main__":
    main()
