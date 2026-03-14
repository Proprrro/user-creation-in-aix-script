# AIX User Creation Automation Script

Shell script used to automate user creation across multiple AIX servers.

## Architecture

The script is executed from a central **AIX jump server** using a with passwordless SSH access to target servers.

Workflow:

Jump Server → SSH → Target AIX Servers

Passwordless authentication is configured using SSH keys so the script can execute remote commands without manual login.

## Features

- Creates user accounts on multiple AIX servers
- Uses passwordless SSH from jump server
- Copies group and configuration from a mirror user
- Automatically sets:
  - UID
  - Home directory
  - Login shell
  - User groups
- Ensures consistent user provisioning across servers

## Environment

- AIX servers
- Bash / Korn shell
- SSH key-based authentication

## Example Flow

1. Script runs on jump server
2. Script connects to target servers using SSH
3. User is created using predefined parameters
4. Group and permissions are copied from a mirror user
5. User account becomes available on all servers
