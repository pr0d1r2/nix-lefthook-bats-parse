#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR"
}

@test "no args exits 0" {
    run lefthook-bats-parse
    assert_success
}

@test "non-existent file is skipped" {
    run lefthook-bats-parse /nonexistent/file.bats
    assert_success
}

@test "non-bats files are skipped" {
    echo 'hello' > "$TMP/readme.md"
    run lefthook-bats-parse "$TMP/readme.md"
    assert_success
}

@test "well-formed bats file passes" {
    cat > "$TMP/good.bats" <<'BATS'
#!/usr/bin/env bats
@test "example" {
    true
}
BATS
    run lefthook-bats-parse "$TMP/good.bats"
    assert_success
}

@test "unclosed @test block fails" {
    cat > "$TMP/bad.bats" <<'BATS'
#!/usr/bin/env bats
@test "broken" {
    true
BATS
    run lefthook-bats-parse "$TMP/bad.bats"
    assert_failure
}

@test "multiple files: only bad one is reported" {
    cat > "$TMP/good.bats" <<'BATS'
#!/usr/bin/env bats
@test "ok" { true; }
BATS
    cat > "$TMP/bad.bats" <<'BATS'
#!/usr/bin/env bats
@test "broken" {
BATS
    run lefthook-bats-parse "$TMP/good.bats" "$TMP/bad.bats"
    assert_failure
    assert_output --partial "bad.bats"
}
