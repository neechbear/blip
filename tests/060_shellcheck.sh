#!/bin/bash

test_060_shellcheck () {
    declare -x blip="${BASH_SOURCE[0]%/*}/../blip.bash"

    # Skip the following test if we don't have the shellcheck command
    # available in the search path.
    is_in_path "shellcheck" || skip

    # https://github.com/koalaman/shellcheck/issues/181
    # This fix doesn't seem to have made it in to the releases of shellcheck
    # that are available for my distribution. :(
    declare output=""; output="$(mktemp)"
    assert_raises "shellcheck -e SC2102 -s bash '$blip' > '$output' 2>&1" 0
    cat "$output" >&2

    assert_end "${BASH_SOURCE[0]##*/}"
}

