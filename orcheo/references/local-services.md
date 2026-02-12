# Start Orcheo local services

## Compose assets

Use bundled assets:
- [assets/docker-compose.yml](../assets/docker-compose.yml)
- [assets/Dockerfile.orcheo](../assets/Dockerfile.orcheo)
- [assets/.env.example](../assets/.env.example)

## Environment setup (required before `docker compose up`)

The `.env` file must be stored in this skill's [assets](../assets/) directory.
Do not use a project-local `.env` from the current working directory.

`SKILL_DIR` should resolve to the directory containing this skill's [SKILL.md](../SKILL.md).

If [assets/.env](../assets/.env) is missing, create it from template:

```bash
cp "${SKILL_DIR}/assets/.env.example" "${SKILL_DIR}/assets/.env"
```

Required secrets to replace before starting local services:
- `ORCHEO_POSTGRES_PASSWORD`
- `ORCHEO_VAULT_ENCRYPTION_KEY`
- `VITE_ORCHEO_CHATKIT_DOMAIN_KEY`
- `ORCHEO_AUTH_BOOTSTRAP_SERVICE_TOKEN`

If these still use template values (`change-me`, `replace-with-64-hex-chars`, etc.), ask the user whether to configure real values now or proceed with placeholders for local testing.

## Bring up stack

Run from the directory containing the compose file, or pass `-f` explicitly.

```bash
docker compose build --no-cache
docker compose up -d
docker compose ps
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
docker compose logs -f backend
docker compose logs -f worker
docker compose logs -f celery-beat
docker compose logs -f canvas
```

## Stop stack

```bash
docker compose down
```

## Notes

- Use PyPI-based images only (this compose builds backend from PyPI packages).
- Confirm [assets/.env](../assets/.env) exists before `up`.
