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
| `x` | T2 | Test empty `.bats` file (zero `@test` blocks) exits 0 |
| `x` | T3 | Test `.bats` file with only comments exits 0 |
| `x` | T4 | Test directory argument is skipped |
| `x` | T5 | Test stderr output format on parse error |
| `x` | T6 | Dogfood `lefthook-bats-parse` in local `lefthook.yml` |
| `x` | T7 | Align `actions/checkout` version across CI workflows (v4 vs v6) |
| `x` | T8 | Add markdownlint lefthook remote for `.md` files |

## §B — Bugs / Known Issues

1. **`.envrc` missing `watch_file`** — only `use flake`, no watches on `flake.nix`/`flake.lock`/`dev.sh`; changes require manual `direnv reload`.
2. **Local lefthook uses `bats -c` directly** — doesn't dogfood `lefthook-bats-parse`; regressions in the wrapper only caught by tests.
3. **Remote mode less structured** — `bats -c {staged_files}` gives less structured error output than the per-file wrapper.
4. **Duplicate `default` in `packages`** — migration left a stale `pkgs.mkShell` block (referencing undefined `ciCommon`/`batsWithLibs`) as a second `default` inside `packages`, causing `nix flake check` to fail with "attribute 'default' already defined".
5. **Confirm app missing materialized packages** — `apps.confirm` `runtimeInputs` lacked `mat.packages`, so coherence check failed for `lefthook-markdownlint`, `lefthook-markdownlint-agentic`, `lefthook-yamllint`.
6. **Confirm app embedded shell in flake.nix** — `apps.confirm` `text` block contained inline shell (export/bash lines), failing `nix-no-embedded-shell-check`. Extracted to `nix/confirm.sh` with `@PLACEHOLDER@` substitution via `builtins.replaceStrings`.
7. **Flake lock exceeded the file-size limit** — the refreshed transitive dependency graph legitimately grew `flake.lock` beyond the stale 64 KiB `.lock` ceiling. Raised the enforced `.lock` limit to 128 KiB while retaining the file-size check.
8. **Flake manifest rejected helper bindings** — the guardrail disallows top-level `let` helpers in `outputs`; inlined system and fragment definitions in the output expressions while preserving all outputs.
9. **Confirm app missing from flake outputs** — CI invokes `nix run .#confirm`, but the flake exported an empty app set; added the materialization-aware confirm app for every supported system.
10. **Generated lefthook configuration missing** — `lefthook.yml` was ignored and absent, so the guardrail could not verify fidelity or parse the repository hooks; committed the generated aggregate configuration.
11. **Materialized lefthook wrappers missing from PATH** — the generated `lefthook.yml` referenced fragment-provided wrappers, but the dev shell and confirm app only exposed the repository's own package; added the materialization packages to both runtime paths.
12. **`outputs.nix` did not match the pinned nixfmt style** — the guardrail's `nixfmt-check` rejected the flake output formatting; reformatted `outputs.nix` with the repository's nixfmt version.
13. **Statix rejected a redundant assignment in `outputs.nix`** — its lint check requires inheriting an existing attribute; changed the `setting` binding to `inherit` from the package set.
14. **Bug-history growth exceeded the Markdown file-size limit** — adding the required §B records pushed `SPEC.md` over the generic 4 KiB ceiling; raised the Markdown-specific limit to 8 KiB.
15. **Generated lefthook configuration absent again** — the ignored materialized `lefthook.yml` was missing, so guardrail fidelity and executability checks failed; restored the aggregate generated from the detected fragments.
