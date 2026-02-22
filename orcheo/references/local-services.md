# Start Orcheo local services

## Compose assets

Preferred source: `orcheo install` syncs stack assets into
`${ORCHEO_STACK_DIR:-$HOME/.orcheo/stack}` and uses the versioned
`stack-v*` release archive when available (with per-file fallback).

## Environment setup (required before `docker compose up`)

Preferred path (recommended):

```bash
orcheo install --yes --start-local-stack
```

This command installs SDK/backend tooling, provisions local-stack assets into
`${ORCHEO_STACK_DIR:-$HOME/.orcheo/stack}`, creates `.env` from `.env.example` if missing,
and starts Docker Compose using that project directory.

Manual path (only if explicit compose control is required):

```bash
STACK_DIR="${ORCHEO_STACK_DIR:-$HOME/.orcheo/stack}"
STACK_VERSION="${ORCHEO_STACK_VERSION:?set ORCHEO_STACK_VERSION (for example: 0.8.3)}"
mkdir -p "$STACK_DIR"
curl -fsSL "https://github.com/ShaojieJiang/orcheo/releases/download/stack-v${STACK_VERSION}/orcheo-stack.tar.gz" \
  -o "$STACK_DIR/orcheo-stack.tar.gz"
tar -xzf "$STACK_DIR/orcheo-stack.tar.gz" -C "$STACK_DIR"
cp -n "$STACK_DIR/.env.example" "$STACK_DIR/.env"
rm -f "$STACK_DIR/orcheo-stack.tar.gz"
```

Manual sync should pin to an explicit stack version (for example `STACK_VERSION=0.8.3`)
instead of pulling mutable `main` branch files.

Required secrets to replace before starting local services:
- `ORCHEO_POSTGRES_PASSWORD`
- `ORCHEO_VAULT_ENCRYPTION_KEY`
- `VITE_ORCHEO_CHATKIT_DOMAIN_KEY`
- `ORCHEO_AUTH_BOOTSTRAP_SERVICE_TOKEN`

If these still use template values (`change-me`, `replace-with-64-hex-chars`, etc.), ask the user whether to configure real values now or proceed with placeholders for local testing.

## Bring up stack

Run from `${ORCHEO_STACK_DIR:-$HOME/.orcheo/stack}`, or pass `-f` and `--project-directory`
explicitly.

```bash
STACK_DIR="${ORCHEO_STACK_DIR:-$HOME/.orcheo/stack}"
docker compose -f "$STACK_DIR/docker-compose.yml" --project-directory "$STACK_DIR" build --no-cache
docker compose -f "$STACK_DIR/docker-compose.yml" --project-directory "$STACK_DIR" up -d
docker compose -f "$STACK_DIR/docker-compose.yml" --project-directory "$STACK_DIR" ps
```

## Expected service names

- `backend`
- `canvas`
- `celery-beat`
- `postgres`
- `redis`
- `worker`

## Logs

```bash
STACK_DIR="${ORCHEO_STACK_DIR:-$HOME/.orcheo/stack}"
docker compose -f "$STACK_DIR/docker-compose.yml" --project-directory "$STACK_DIR" logs -f backend
docker compose -f "$STACK_DIR/docker-compose.yml" --project-directory "$STACK_DIR" logs -f worker
docker compose -f "$STACK_DIR/docker-compose.yml" --project-directory "$STACK_DIR" logs -f celery-beat
docker compose -f "$STACK_DIR/docker-compose.yml" --project-directory "$STACK_DIR" logs -f canvas
```

## Stop stack

```bash
STACK_DIR="${ORCHEO_STACK_DIR:-$HOME/.orcheo/stack}"
docker compose -f "$STACK_DIR/docker-compose.yml" --project-directory "$STACK_DIR" down
```

## Notes

- Use PyPI-based images only (this compose builds backend from PyPI packages).
- Confirm `${ORCHEO_STACK_DIR:-$HOME/.orcheo/stack}/.env` exists before `up`.
- If reproducibility matters, pass `--stack-version <X.Y.Z>` to `orcheo install`.
