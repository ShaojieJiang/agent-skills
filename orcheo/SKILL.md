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

```bash
orcheo --help
orcheo <command> --help
```

## Resources

Use the bundled compose file at `assets/docker-compose.yml`, `assets/Dockerfile.orcheo`, and `assets/.env.example` as a starting point for running Orcheo with Postgres, Redis, Celery worker/beat, and Canvas.
