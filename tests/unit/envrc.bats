#!/usr/bin/env bats

@test ".envrc watches flake and dev shell inputs" {
    for file in flake.nix flake.lock dev.sh; do
        run grep -Fx "watch_file $file" .envrc
        [ "$status" -eq 0 ]
    done
}
