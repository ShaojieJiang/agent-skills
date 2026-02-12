---
name: orcheo
description: Bootstrap Orcheo CLI usage, configure profiles, run local Orcheo services with the bundled PyPI-based docker compose assets, and execute common `orcheo` workflow/credential/coding operations.
---

# Orcheo

Instructions for Orcheo CLI booting, configuration, local services, operations, and coding workflows.
When you need command details, use `orcheo --help` or `orcheo <subcommand> --help`.

## Quick start

1. Run [booting.md](./references/booting.md) first.
2. After booting succeeds, load only the reference file needed for the user request.

## Reference map

- [REFERENCE.md](./references/REFERENCE.md)
- [config.md](./references/config.md)
- [local-services.md](./references/local-services.md)
- [operations.md](./references/operations.md)
- [coding.md](./references/coding.md)

## Scope and rules

- Use only PyPI-based compose workflows for local services in this skill.
- Ask for confirmation before package installation, compose up/down, auth login, or file changes.
- Prefer concise, copy-pasteable commands.
