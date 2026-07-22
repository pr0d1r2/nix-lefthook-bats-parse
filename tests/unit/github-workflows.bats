#!/usr/bin/env bats

@test "CI workflows use at most one actions/checkout major version" {
    run bash -c '
        versions="$(grep -hEo "actions/checkout@v[0-9]+" .github/workflows/* 2>/dev/null \
            | sort -u)"
        [ "$(printf "%s\n" "$versions" | sed "/^$/d" | wc -l)" -le 1 ]
    '
    [ "$status" -eq 0 ]
}
