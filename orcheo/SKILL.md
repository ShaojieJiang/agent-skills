---
name: orcheo
description: Install Orcheo Python packages and Canvas from PyPI/npm, start Orcheo services with docker compose using PyPI-based images only, and run Orcheo CLI commands. Use when setting up Orcheo from scratch, updating installs, launching production or local stacks via docker compose, or executing `orcheo`/`orcheo-canvas` CLI workflows.
---

# Orcheo

## Overview

Install Orcheo core, backend, and SDK from the latest PyPI packages, install the Canvas UI from npm, start services with docker compose when explicitly requested, and execute Orcheo CLI commands. Do not assume the user has the Orcheo source repo; use the bundled compose asset or ask for any required compose file or deployment details. Only support PyPI-based images/installs for compose setups. Prefer minimal, copy-pasteable commands and confirm OS, Python, and node/npm availability if not stated. Always ask for confirmation before installing/upgrading packages, changing compose files, or starting the Orcheo stack.

## Install Orcheo (PyPI)

Use a virtual environment when possible, then install or upgrade all three packages together. Default to the latest PyPI releases.

Ask for confirmation before running any install/upgrade command.

```bash
python -m pip install -U orcheo orcheo-backend orcheo-sdk
```

If the user prefers uv, use this equivalent:

```bash
uv pip install -U orcheo orcheo-backend orcheo-sdk
```

Verify the CLI is available:

```bash
orcheo --help
```

## Install Orcheo Canvas (npm)

Install the Canvas CLI from npm. Prefer global install for quick usage or `npx` for one-off runs.

Ask for confirmation before running any install/upgrade command.

```bash
npm install -g orcheo-canvas
```

One-off alternative:

```bash
npx orcheo-canvas --help
```

## Start services (docker compose)

Only use docker compose when the user explicitly requests a containerized setup. If the user does not have a compose file, offer the bundled `assets/docker-compose.yml` and `assets/Dockerfile.orcheo` and ask where to place them. The bundle mirrors the repo stack with Postgres, Redis, the Orcheo API, Celery worker/beat, and Canvas, and builds the backend image locally by installing the latest PyPI packages. If the user has a source-based compose, guide them to use the bundled PyPI-based compose instead of modifying a source-based stack. Ask the user to set required secrets (at minimum `ORCHEO_POSTGRES_PASSWORD`, `ORCHEO_VAULT_ENCRYPTION_KEY`, and `VITE_ORCHEO_CHATKIT_DOMAIN_KEY`) and to configure auth values or switch `ORCHEO_AUTH_MODE` to `optional` for local testing. Use the bundled `assets/.env.example` as a starting point for required variables.

Ask for confirmation before starting or stopping any services.

If the user already has a `docker-compose.yml`, run commands from its directory and confirm services are up:

```bash
docker compose up -d
docker compose ps
```

Use logs for troubleshooting and stop services when done:

```bash
docker compose logs -f backend
docker compose logs -f worker
docker compose logs -f celery-beat
docker compose logs -f canvas
docker compose down
```

If the compose file uses different service names, substitute the correct service for log tailing.

## Orcheo CLI commands

Run Orcheo CLI commands via the `orcheo` executable from the SDK. Ask for the exact command, working directory, and any required config or env vars, then execute and report output.

### Before running any `orcheo` command

1. **Check if `uv` is available**: Run `which uv` (macOS/Linux) or `where uv` (Windows) first to determine the package manager to use.

2. **Handle `.env` file first**: The `.env` file must be stored in this skill's `assets/` directory. **Never use a `.env` file from the current working directory.** Use the `SKILL_DIR` placeholder (resolved by the skill runner) or determine the skill directory path explicitly. **Always load environment variables from `assets/.env` before running any `orcheo` command.**
   - **If `assets/.env` is missing**: You MUST create it by copying `assets/.env.example` to `assets/.env`. Use the appropriate command for the OS:
     - **macOS/Linux**: `cp "${SKILL_DIR}/assets/.env.example" "${SKILL_DIR}/assets/.env"`
     - **Windows**: `copy "${SKILL_DIR}\assets\.env.example" "${SKILL_DIR}\assets\.env"`
   - **After creating the file**: Inform the user that a `.env` file has been created at `${SKILL_DIR}/assets/.env` with default values. List the required secrets that need to be configured:
     - `ORCHEO_POSTGRES_PASSWORD` - Database password
     - `ORCHEO_VAULT_ENCRYPTION_KEY` - 64-character hex string for encryption
     - `VITE_ORCHEO_CHATKIT_DOMAIN_KEY` - ChatKit domain key
     - `ORCHEO_AUTH_SERVICE_TOKEN` - Auth service token
     - `ORCHEO_AUTH_BOOTSTRAP_SERVICE_TOKEN` - Bootstrap service token
   - **CRITICAL: STOP AND ASK THE USER** - You MUST use the AskUserQuestion tool to ask the user if they want to configure these values now or come back later. **DO NOT proceed with any orcheo commands until the user has either configured the secrets or explicitly chosen to skip.** The default template values (`change-me`, `replace-with-64-hex-chars`, etc.) will NOT work for most operations.
     - If the user wants to configure now: Help them edit the `.env` file with their actual values before proceeding.
     - If the user wants to come back later: **STOP HERE.** Remind them to run the orcheo skill again after configuring the `.env` file. Do not attempt to run any orcheo commands with placeholder values.
   - **Load environment variables before any orcheo command** (using the skill's assets directory):
     - **Bash/Zsh**: `export $(grep -v '^#' "${SKILL_DIR}/assets/.env" | grep -v '^$' | xargs)`
     - **Fish**: `export (grep -v '^#' "${SKILL_DIR}/assets/.env" | grep -v '^$' | xargs)`
     - **Windows PowerShell**: Load each line from `${SKILL_DIR}/assets/.env` as `$env:VAR=VALUE`
   - **Important**: The `SKILL_DIR` variable should point to the directory containing this SKILL.md file. If not set, determine it by locating the `agent-skills/orcheo/` directory in the user's filesystem.

3. **Check if `orcheo` is installed** (after loading env vars):
   - **With uv (preferred)**: Run `uv run orcheo --help`. If it fails, install with `uv pip install -U orcheo orcheo-backend orcheo-sdk`
   - **Without uv (fallback)**: Run `orcheo --help`. If the command is not found, install using:
     - **macOS/Linux**: `python -m pip install -U orcheo orcheo-backend orcheo-sdk`
     - **Windows**: `py -m pip install -U orcheo orcheo-backend orcheo-sdk`

4. **If you encounter a connection error** (e.g., "Connection refused", "Failed to reach http://localhost:8000"):
   - **NEVER** try alternative URLs or guess from env vars—ask the user if they want to start services with `docker compose -f "${SKILL_DIR}/assets/docker-compose.yml" up -d`, then retry.

```bash
# Load env vars first, then run orcheo commands
# SKILL_DIR should be set to the directory containing this SKILL.md file
# Example: SKILL_DIR="/path/to/agent-skills/orcheo"

# With uv (preferred)
export $(grep -v '^#' "${SKILL_DIR}/assets/.env" | grep -v '^$' | xargs) && uv run orcheo --help
export $(grep -v '^#' "${SKILL_DIR}/assets/.env" | grep -v '^$' | xargs) && uv run orcheo <command> --help

# Without uv (fallback)
export $(grep -v '^#' "${SKILL_DIR}/assets/.env" | grep -v '^$' | xargs) && orcheo --help
export $(grep -v '^#' "${SKILL_DIR}/assets/.env" | grep -v '^$' | xargs) && orcheo <command> --help
```

## Resources

Use the bundled compose file at `assets/docker-compose.yml`, `assets/Dockerfile.orcheo`, and `assets/.env.example` as a starting point for running Orcheo with Postgres, Redis, Celery worker/beat, and Canvas.
