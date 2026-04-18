# nix-lefthook-bats-parse

[![CI](https://github.com/pr0d1r2/nix-lefthook-bats-parse/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-bats-parse/actions/workflows/ci.yml)

> This code is LLM-generated and validated through an automated integration process using [lefthook](https://github.com/evilmartians/lefthook) git hooks, [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible [Bats](https://github.com/bats-core/bats-core) parse checker, packaged as a Nix flake.

Validates `.bats` file syntax via `bats -c`. Catches malformed `@test` blocks at pre-commit time. Exits 0 when no matching files are found.

## Usage

### Option A: Lefthook remote (recommended)

Add to your `lefthook.yml` — no flake input needed, just `pkgs.bats` in your devShell:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-bats-parse
    ref: main
    configs:
      - lefthook-remote.yml
```

### Option B: Flake input

Add as a flake input:

```nix
inputs.nix-lefthook-bats-parse = {
  url = "github:pr0d1r2/nix-lefthook-bats-parse";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add to your devShell:

```nix
nix-lefthook-bats-parse.packages.${pkgs.stdenv.hostPlatform.system}.default
```

Add to `lefthook.yml`:

```yaml
pre-commit:
  commands:
    bats-parse:
      glob: "*.bats"
      run: timeout ${LEFTHOOK_BATS_PARSE_TIMEOUT:-30} lefthook-bats-parse {staged_files}
```

### Configuring timeout

The default timeout is 30 seconds. Override per-repo via environment variable:

```bash
export LEFTHOOK_BATS_PARSE_TIMEOUT=60
```

## Development

The repo includes an `.envrc` for [direnv](https://direnv.net/) — entering the directory automatically loads the devShell with all dependencies:

```bash
cd nix-lefthook-bats-parse  # direnv loads the flake
bats tests/unit/
```

If not using direnv, enter the shell manually:

```bash
nix develop
bats tests/unit/
```

## License

MIT
