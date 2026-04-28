# Paperclip Fly.io Deployment Guide for Agents

This document outlines the standard procedure for deploying and maintaining Paperclip on Fly.io.

## Prerequisites

1.  **Fly CLI:** Must be installed and authenticated (`fly auth login`).
2.  **Environment:** Windows agents must handle line endings (LF) carefully for scripts intended for Linux containers.

## Initial Setup & Infrastructure

### 1. App Creation
```powershell
fly apps create <app-name>
```

### 2. Persistent Storage (CRITICAL)
Paperclip requires a persistent volume. This is also where your adapter logins (Claude/Codex) will be stored.
```powershell
fly volumes create paperclip_data --region <region> --size 10 --app <app-name>
```

### 3. Secrets Configuration
```powershell
fly secrets set BETTER_AUTH_SECRET=$(openssl rand -hex 32) --app <app-name>
```

## Critical Fixes for Fly.io

### 1. Volume Permissions
The `scripts/docker-entrypoint.sh` must fix ownership so the `node` user can write to the volume.
```bash
#!/bin/sh
set -e
chown -R node:node /paperclip
exec gosu node "$@"
```

### 2. Line Endings
Always convert `scripts/docker-entrypoint.sh` to **LF** before deploying from Windows.

## Post-Deployment: Adapter Persistence (Claude/Codex)

To prevent losing your login sessions when the VM restarts, you **must** force the configuration to be saved in the persistent volume.

### 1. Claude Code Login
```powershell
fly ssh console -a <app-name>
# Inside the shell:
HOME=/paperclip claude login
```

### 2. Codex Login
```powershell
fly ssh console -a <app-name>
# Inside the shell:
HOME=/paperclip codex login --device-auth
```

### 3. Verification & Restart
After logging in, you can restart the machine to verify persistence:
```powershell
fly machine restart --app <app-name> --all
```

## SSH & Process Management

- **Interactive Shell:** `fly ssh console -a <app-name>`
- **Restart Paperclip Process (only):** Inside SSH, run `pkill -9 node`. The machine will briefly stop and Fly will auto-restart the process.
- **View Logs:** `fly logs -a <app-name>`

## Troubleshooting
- **Login disappears:** You probably ran `claude login` without the `HOME=/paperclip` prefix. Credentials went to the ephemeral `/root` folder and were lost.
