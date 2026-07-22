#!/usr/bin/env bats

@test "pre-commit dogfoods lefthook-bats-parse with timeout" {
    run grep -F 'run: timeout ${LEFTHOOK_BATS_PARSE_TIMEOUT:-30} lefthook-bats-parse {staged_files}' lefthook-repo.yml
    [ "$status" -eq 0 ]
}

@test "pre-push dogfoods lefthook-bats-parse with timeout" {
    run grep -F 'run: timeout ${LEFTHOOK_BATS_PARSE_TIMEOUT:-30} lefthook-bats-parse {push_files}' lefthook-repo.yml
    [ "$status" -eq 0 ]
}
