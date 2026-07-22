#!/usr/bin/env bats

@test "loads the markdownlint remote for markdown files" {
    run grep -A4 -F 'git_url: https://github.com/pr0d1r2/nix-lefthook-markdownlint' lefthook-repo.yml
    [ "$status" -eq 0 ]
    [[ "$output" == *"ref: main"* ]]
    [[ "$output" == *"- lefthook-remote.yml"* ]]
}

@test "pre-commit dogfoods lefthook-bats-parse with timeout" {
    run grep -F 'run: timeout ${LEFTHOOK_BATS_PARSE_TIMEOUT:-30} lefthook-bats-parse {staged_files}' lefthook-repo.yml
    [ "$status" -eq 0 ]
}

@test "pre-push dogfoods lefthook-bats-parse with timeout" {
    run grep -F 'run: timeout ${LEFTHOOK_BATS_PARSE_TIMEOUT:-30} lefthook-bats-parse {push_files}' lefthook-repo.yml
    [ "$status" -eq 0 ]
}
