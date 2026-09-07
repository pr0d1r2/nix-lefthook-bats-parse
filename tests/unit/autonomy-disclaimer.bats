#!/usr/bin/env bats

@test "README autonomy disclaimer is one marker-managed line with a link" {
    run awk '
        /<!-- hallucinogen:autonomy-disclaimer start -->/ { in_block = 1; next }
        /<!-- hallucinogen:autonomy-disclaimer end -->/ { in_block = 0; next }
        in_block {
            lines++
            if ($0 !~ /^> Read \[LLM-DISCLAIMER\]\(docs\/LLM-DISCLAIMER\.md\)/) invalid = 1
        }
        END { exit (lines == 1 && !invalid) ? 0 : 1 }
    ' README.md
    [ "$status" -eq 0 ]
}
