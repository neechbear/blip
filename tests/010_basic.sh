#!/bin/bash

test_010_basic () {
    declare -x blip="${BASH_SOURCE[0]%/*}/../blip.bash"

    # Try loading blip.
    assert_raises "bash -c '_clear_blip; . \"$blip\"'" 0

    # Require a newer version of blip.
    assert_raises "bash -c '_clear_blip; BLIP_REQUIRE_VERSION=999.999-999; . \"$blip\"'" 2
    #assert "bash -c '_clear_blip; BLIP_REQUIRE_VERSION=999.999-999; . \"$blip\"' 2>&1" \
    #    "blip.bash version 0.4-1-alpha does not satisfy minimum required version 999.999-999; exiting!"
    assert "_clear_blip; . \"$blip\" 2>&1'" ""

    assert_end "${BASH_SOURCE[0]##*/}"
}

