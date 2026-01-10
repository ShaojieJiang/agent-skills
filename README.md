# Skills

This directory contains AI agent skills used by this repository. Each skill
defines how an AI agent should help with a specific workflow.

## How to use a skill
- Ask for a skill by name in your request (e.g., "use the orcheo skill").
- You can describe the task instead; an AI agent may pick a matching skill when
  it clearly applies.
- The AI agent will read the skill's `SKILL.md` and follow its instructions.

## What to expect
- Copy-pasteable commands and minimal, safe steps.
- Questions when details are missing (OS, versions, paths, credentials).
- A request for confirmation before installs, upgrades, or starting services.

## Where the details live
- Each skill lives in `skills/<skill_name>/`.
- Read `skills/<skill_name>/SKILL.md` for the full workflow and requirements.
- Supporting files (like templates or compose files) live in
  `skills/<skill_name>/assets/`.

## Install in common agents
### Codex CLI
- Copy or symlink this skill to your Codex skills folder:
  - `mkdir -p ~/.codex/skills`
  - `cp -R skills/orcheo ~/.codex/skills/`
- Ask for it by name in your prompt (e.g., "use the orcheo skill").

### Claude Code
- Add a note to `CLAUDE.md` telling Claude Code to read
  `skills/orcheo/SKILL.md` when Orcheo tasks come up.
- If you prefer, paste the relevant instructions from
  `skills/orcheo/SKILL.md` directly into `CLAUDE.md`.

### Cursor
- Add a Project Rule that tells Cursor to read `skills/orcheo/SKILL.md`.
- Or paste the relevant instructions into a rule file or the Rules UI.

## Tips for skill users
- Share your OS, shell, and project path when it matters.
- If you want a specific command run, include it verbatim.
- For setup tasks, confirm whether you want global or project-local installs.
