#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TEST_DIR="$(mktemp -d)"

    sed \
        -e 's|@FRAGMENTS_DIR@|/test/fragments|' \
        -e 's|@ASSEMBLE_SCRIPT@|/test/assemble.sh|' \
        -e 's|@DETECT_SCRIPT@|/test/detect.sh|' \
        -e 's|@SETTING_SRC@|/test/setting|' \
        -e 's|@CONFIRM_SCRIPT@|'"$TEST_DIR"'/confirm_stub.sh|' \
        -e 's|@CONFIRM_REV@|abc123|' \
        nix/confirm.sh > "$TEST_DIR/confirm.sh"

    cat > "$TEST_DIR/confirm_stub.sh" <<'SH'
#!/usr/bin/env bash
echo "FRAGMENTS_DIR=$FRAGMENTS_DIR"
echo "ASSEMBLE_SCRIPT=$ASSEMBLE_SCRIPT"
echo "DETECT_SCRIPT=$DETECT_SCRIPT"
echo "SETTING_SRC=$SETTING_SRC"
echo "CONFIRM_SCRIPT=$CONFIRM_SCRIPT"
echo "CONFIRM_REV=$CONFIRM_REV"
SH
    chmod +x "$TEST_DIR/confirm_stub.sh"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "exports FRAGMENTS_DIR from placeholder" {
    run bash "$TEST_DIR/confirm.sh"
    assert_success
    assert_line "FRAGMENTS_DIR=/test/fragments"
}

@test "exports ASSEMBLE_SCRIPT from placeholder" {
    run bash "$TEST_DIR/confirm.sh"
    assert_success
    assert_line "ASSEMBLE_SCRIPT=/test/assemble.sh"
}

@test "exports DETECT_SCRIPT from placeholder" {
    run bash "$TEST_DIR/confirm.sh"
    assert_success
    assert_line "DETECT_SCRIPT=/test/detect.sh"
}

@test "exports SETTING_SRC from placeholder" {
    run bash "$TEST_DIR/confirm.sh"
    assert_success
    assert_line "SETTING_SRC=/test/setting"
}

@test "exports CONFIRM_SCRIPT from placeholder" {
    run bash "$TEST_DIR/confirm.sh"
    assert_success
    assert_line "CONFIRM_SCRIPT=$TEST_DIR/confirm_stub.sh"
}

@test "exports CONFIRM_REV from placeholder" {
    run bash "$TEST_DIR/confirm.sh"
    assert_success
    assert_line "CONFIRM_REV=abc123"
}

@test "invokes CONFIRM_SCRIPT via bash" {
    cat > "$TEST_DIR/confirm_stub.sh" <<'SH'
#!/usr/bin/env bash
echo "confirm_invoked"
SH
    chmod +x "$TEST_DIR/confirm_stub.sh"
    run bash "$TEST_DIR/confirm.sh"
    assert_success
    assert_output "confirm_invoked"
}
