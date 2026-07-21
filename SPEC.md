# SPEC — nix-lefthook-bats-parse

## §D — Description

Nix-flake-packaged lefthook check that validates `.bats` file syntax via `bats -c`,
catching malformed `@test` blocks at pre-commit/pre-push time.
Ships as a lefthook remote (zero-config YAML stanza) or a Nix package with per-file error reporting.
Targets Nix+lefthook+bats projects on Linux and macOS (amd64/arm64).

## §V — Invariants

1. Zero arguments → exit 0
2. Non-existent files silently skipped (exit 0)
3. Non-`.bats` files silently skipped (exit 0)
4. Well-formed `.bats` → exit 0; unclosed `@test` → exit 1
5. Multi-file: exit 1 if any fail; only broken file reported on stderr
6. `dev.sh` sets `BATS_LIB_PATH` from `@BATS_LIB_PATH@` placeholder
7. `dev.sh` runs `lefthook install` only when `.git/hooks/pre-commit` absent
8. Flake builds on aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux
9. CI: Linux on all triggers; macOS on push/dispatch only
10. All lefthook commands in both pre-commit and pre-push with timeout
11. No shell functions; no embedded shell in Nix files

## §I — Interfaces

### CLI

`lefthook-bats-parse [file.bats ...]` — stderr: `<path>: parse error`; exit 0 (ok/skip) or 1 (error).

### Flake outputs

- `packages.<system>.default` — the wrapper script with `bats` runtime input
- `devShells.<system>.default` — dev shell with tools + `dev.sh` hook
- `devShells.<system>.ci` — CI shell (no hook, exports `BATS_LIB_PATH`)

### Environment variables

- `LEFTHOOK_BATS_PARSE_TIMEOUT` (default `30`) — timeout seconds
- `BATS_LIB_PATH` — bats helper libraries path (set by dev shell)

### Config files

- `lefthook-remote.yml` — exported config for consumers
- `config/lefthook/file_size_limits.yml` — per-extension size limits

## §T — Tasks

| status | id | goal |
|---|---|---|
| `x` | T1 | Add `watch_file` entries to `.envrc` for `flake.nix`, `flake.lock`, `dev.sh` |
| `.` | T2 | Test empty `.bats` file (zero `@test` blocks) exits 0 |
| `.` | T3 | Test `.bats` file with only comments exits 0 |
| `.` | T4 | Test directory argument is skipped |
| `.` | T5 | Test stderr output format on parse error |
| `.` | T6 | Dogfood `lefthook-bats-parse` in local `lefthook.yml` |
| `.` | T7 | Align `actions/checkout` version across CI workflows (v4 vs v6) |
| `.` | T8 | Add markdownlint lefthook remote for `.md` files |

## §B — Bugs / Known Issues

1. **`.envrc` missing `watch_file`** — only `use flake`, no watches on `flake.nix`/`flake.lock`/`dev.sh`; changes require manual `direnv reload`.
2. **Local lefthook uses `bats -c` directly** — doesn't dogfood `lefthook-bats-parse`; regressions in the wrapper only caught by tests.
3. **`actions/checkout` version mismatch** — `ci.yml` (v6) vs `update-pins.yml` (v4).
4. **Remote mode less structured** — `bats -c {staged_files}` gives less structured error output than the per-file wrapper.
5. **Duplicate `default` in `packages`** — migration left a stale `pkgs.mkShell` block (referencing undefined `ciCommon`/`batsWithLibs`) as a second `default` inside `packages`, causing `nix flake check` to fail with "attribute 'default' already defined".
6. **Confirm app missing materialized packages** — `apps.confirm` `runtimeInputs` lacked `mat.packages`, so coherence check failed for `lefthook-markdownlint`, `lefthook-markdownlint-agentic`, `lefthook-yamllint`.
7. **Confirm app embedded shell in flake.nix** — `apps.confirm` `text` block contained inline shell (export/bash lines), failing `nix-no-embedded-shell-check`. Extracted to `nix/confirm.sh` with `@PLACEHOLDER@` substitution via `builtins.replaceStrings`.
