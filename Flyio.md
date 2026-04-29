# Paperclip Fly.io Deployment Guide for Agents

This document outlines the standard procedure for deploying and maintaining Paperclip on Fly.io.

## Prerequisites

1. **Fly CLI:** Must be installed and authenticated (`fly auth login`).
2. **Environment:** Windows agents must handle line endings (LF) carefully for scripts intended for Linux containers.

## Initial Setup & Infrastructure

### 1. App Creation

```powershell
fly apps create <app-name>
```

### 2. Persistent Storage (CRITICAL)

Paperclip requires a persistent volume. This is also where your adapter logins (Claude/Codex/Gemini/GitHub) will be stored.

```powershell
fly volumes create paperclip_data --region <region> --size 10 --app <app-name>
```

### 3. Secrets Configuration

```powershell
fly secrets set BETTER_AUTH_SECRET=$(openssl rand -hex 32) --app <app-name>
```

## Critical Fixes for Fly.io

### 1. Volume Permissions & Postgres

The `scripts/docker-entrypoint.sh` must fix ownership and specific Postgres permissions (0700 for db folder).

```bash
#!/bin/sh
set -e
chown -R node:node /paperclip
chmod -R 755 /paperclip
find /paperclip -type d -name "db" -exec chmod 700 {} +
exec gosu node "$@"
```

### 2. Line Endings

Always convert `scripts/docker-entrypoint.sh` to **LF** before deploying from Windows.

## Post-Deployment: Admin & Adapter Setup

To prevent losing login sessions when the VM restarts, you **must** force configurations to the persistent volume.

### 1. Create Minimal Config (Required for CLI)

```powershell
$json = '{"$meta":{"version":1,"updatedAt":"2026-04-28T14:00:00Z","source":"onboard"},"database":{"mode":"embedded-postgres","embeddedPostgresPort":54329},"logging":{"mode":"file"},"server":{"deploymentMode":"authenticated","exposure":"public","bind":"lan","host":"0.0.0.0","port":3100},"auth":{"baseUrlMode":"explicit","publicBaseUrl":"https://<app-name>.fly.dev"}}';
$b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($json));
fly ssh console -a <app-name> -C "sh -c 'mkdir -p /paperclip/instances/default && echo $b64 | base64 -d > /paperclip/instances/default/config.json'"
```

### 2. Generate Bootstrap CEO Invite

```powershell
fly ssh console -a <app-name> -C "pnpm paperclipai auth bootstrap-ceo --base-url https://<app-name>.fly.dev"
```

### 3. Claude Code Login

```powershell
fly ssh console -a <app-name>
# Inside the shell:
HOME=/paperclip claude login
```

### 4. Codex Login

```powershell
fly ssh console -a <app-name> -C "HOME=/paperclip codex login --device-auth"
```

### 5. Gemini CLI Login

```powershell
fly ssh console -a <app-name>
# Inside the shell:
HOME=/paperclip gemini auth login
```

### 6. GitHub CLI Login

```powershell
fly ssh console -a <app-name>
# Inside the shell:
HOME=/paperclip gh auth login
```

## SSH & Process Management

- **Interactive Shell:** `fly ssh console -a <app-name>`
- **Restart Paperclip Process (only):** Inside SSH, run `pkill -9 node`. The machine will briefly stop and Fly will auto-restart the process.
- **View Logs:** `fly logs -a <app-name>`

## Troubleshooting

- **Login disappears:** Ensure you use `HOME=/paperclip` before any CLI login command.
- **Permission Denied:** The entrypoint should fix this, but you can manually run `chown -R node:node /paperclip` via SSH if needed.
