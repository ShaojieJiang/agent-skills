---
name: orcheo
description: Install Orcheo Python packages and Canvas from PyPI/npm, start Orcheo services with docker compose using PyPI-based images only, and run Orcheo CLI commands. Use when setting up Orcheo from scratch, updating installs, launching production or local stacks via docker compose, or executing `orcheo`/`orcheo-canvas` CLI workflows.
---

# Orcheo

## Overview

Install Orcheo core and backend from the latest PyPI packages with uv, install the Orcheo CLI via `uv tool install orcheo-sdk`, install the Canvas UI from npm, start services with docker compose when explicitly requested, and execute Orcheo CLI commands.

Do not assume the user has the Orcheo source repo; use the bundled compose asset or ask for any required compose file or deployment details. Only support PyPI-based images/installs for compose setups.

Prefer minimal, copy-pasteable commands and confirm OS, Python, and node/npm availability if not stated. Always ask for confirmation before installing/upgrading packages, changing compose files, or starting the Orcheo stack.

uv is required for Orcheo installs and CLI usage; ask the user to install uv first if it is missing.

## Install Orcheo (PyPI)

Use a virtual environment when possible, then install or upgrade Orcheo core and backend together. Default to the latest PyPI releases.

The `orcheo-sdk` package is installed separately as a standalone CLI tool via `uv tool install`, which makes the `orcheo` command globally available without activating a virtual environment. If you need the SDK as a library dependency in your project (for development purposes), also run `uv pip install orcheo-sdk` in your project's virtual environment.

Ask for confirmation before running any install/upgrade command.

```bash
uv pip install -U orcheo orcheo-backend
uv tool install orcheo-sdk
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

> **Note on `${SKILL_DIR}`**: Throughout this section, `${SKILL_DIR}` is a placeholder representing the absolute path to the directory containing this SKILL.md file. Agents should resolve this path before executing commands—either by using an environment variable if the skill runner provides one, or by programmatically determining the location of this SKILL.md file. Replace `${SKILL_DIR}` with the actual resolved path in all commands.

#### Initial Setup (One-time)

1. **Ensure `uv` is installed**: Run `which uv` (macOS/Linux) or `where uv` (Windows). If missing, direct the user to install it from https://docs.astral.sh/uv/getting-started/installation/ before proceeding.

2. **Handle `.env` file**: The `.env` file must be stored in this skill's `assets/` directory. **Never use a `.env` file from the current working directory.** Use the `SKILL_DIR` placeholder (resolved by the skill runner) or determine the skill directory path explicitly.
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
   - **Important**: The `SKILL_DIR` variable should point to the directory containing this SKILL.md file. If not set, determine it by locating the directory containing this SKILL.md file in the user's filesystem.

3. **Check if `orcheo` is installed**: Run `orcheo --help`. If it fails, install with `uv tool install orcheo-sdk`, then retry.

4. **Configure CLI profiles**: After the `.env` file is ready, run `orcheo config` pointing at the skill `.env` file. This writes configuration to `~/.config/orcheo/cli.toml` and removes the need to export `.env` variables before each command.

   The `orcheo config` command supports the following options:
   - `--env-file <path>`: Path to the `.env` file (defaults to searching for `.env` in current directory)
   - `--profile <name>`: Named profile for the configuration (default profile is used if omitted)
   - `--service-token <token>`: Service token for authentication with remote Orcheo instances

   Service tokens are used for authenticating with remote Orcheo API instances. If you need to store a service token in the CLI configuration, either add `ORCHEO_SERVICE_TOKEN` to your `.env` file or pass `--service-token` directly to the `orcheo config` command.

   Re-run `orcheo config` if the `.env` values change.

   Examples:
   ```bash
   # Write default profile from .env file
   orcheo config --env-file "${SKILL_DIR}/assets/.env"

   # Write additional named profile (e.g., for staging environment)
   orcheo config --env-file "${SKILL_DIR}/assets/.env.staging" --profile staging

   # Use a specific profile
   orcheo --profile staging <command>
   ```

#### Troubleshooting

5. **If you encounter a connection error** (e.g., "Connection refused", "Failed to reach http://localhost:8000"):
   - **NEVER** try alternative URLs or guess from env vars—ask the user if they want to start services with `docker compose -f "${SKILL_DIR}/assets/docker-compose.yml" up -d`, then retry.

#### Running Commands

Once the initial setup is complete, you can run orcheo commands without exporting environment variables:

```bash
# SKILL_DIR should be set to the directory containing this SKILL.md file
# Example: SKILL_DIR="/path/to/orcheo-skill"

orcheo --help
orcheo <command> --help
```

## Resources

Use the bundled compose file at `assets/docker-compose.yml`, `assets/Dockerfile.orcheo`, and `assets/.env.example` as a starting point for running Orcheo with Postgres, Redis, Celery worker/beat, and Canvas.
