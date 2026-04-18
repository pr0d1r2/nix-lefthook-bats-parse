# shellcheck shell=bash
# Parse-only validation for .bats files via `bats -c`.
# Catches malformed @test blocks at pre-commit time.
# Usage: lefthook-bats-parse file1.bats [file2.bats ...]
# Non-.bats files are skipped silently.
# NOTE: sourced by writeShellApplication — no shebang or set needed.

if [ $# -eq 0 ]; then
    exit 0
fi

failed=0
for f in "$@"; do
    [ -f "$f" ] || continue
    case "$f" in
        *.bats) ;;
        *) continue ;;
    esac

    if ! out="$(bats -c "$f" 2>&1)"; then
        echo "$f: parse error" >&2
        printf '%s\n' "$out" >&2
        failed=1
    fi
done

exit "$failed"
