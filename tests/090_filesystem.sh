#!/bin/bash

_blip_test_stat_stub () {
    if [[ $# -ne 3 ]] ; then
        >&2 echo "Unexpected number of args to stat stub (expected 3, got $#)"
    elif [[ ! "${1:-}" = "-c" ]] ; then
        >&2 echo "Unexpected arg1 passed to stat stub (expected '-c', got '${1:-}')"
    elif [[ ! "${2:-}" = "%Y" ]] ; then
        >&2 echo "Unexpected arg2 passed to stat stub (expected '%Y', got '${2:-}')"
    elif [[ ! "${3:-}" =~ ^/tmp/[a-zA-Z0-9\.]+ ]] ; then
        >&2 echo "Unexpected arg3 passed to stat stub (expected a filename, got '${3:-}')"
    else
        echo "$_blip_test_stat_unixtime"
        return 0
    fi
    return 2
}

test_090_filesystem () {
    assert_raises "is_in_path 'bash'" 0
    assert_raises "is_in_path '_InVenTed_CommAnd_Not_In_PATH__'" 1

    declare -x _old_stat_cmd="${BLIP_EXTERNAL_CMD_STAT:-stat}"
    declare -x _blip_test_stat_unixtime=1470000000
    BLIP_EXTERNAL_CMD_STAT="_blip_test_stat_stub"
    assert_raises "get_file_age '/tmp/foo1'" 0

    declare -x result1=""
    declare -x result2=""
    result1="$(get_file_age /tmp/foo1)"
    _blip_test_stat_unixtime=1470010000
    result2="$(get_file_age /tmp/foo2)"
    assert_raises "[[ $(( result1 - result2 )) -ge 10000 ]] && [[ $(( result1 - result2 )) -le 10005 ]]" 0

    BLIP_EXTERNAL_CMD_STAT="$_old_stat_cmd"

    assert_end "${BASH_SOURCE[0]##*/}"
}

