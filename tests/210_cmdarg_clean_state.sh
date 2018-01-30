#!/bin/bash
# shellcheck disable=SC2154

test_210_1_clean_state_usable () {
  function parse1 () {
    cmdarg 'a:' 'a' 'some arg'
    cmdarg 'b' 'b' 'some arg'
    cmdarg_parse "$@"
  }

  function parse2 () {
    cmdarg_purge
    cmdarg 'c:' 'c' 'some arg'
    cmdarg 'd' 'd' 'some arg'
    cmdarg_parse "$@"
  }

  assert_raises "parse1 -a 3 -b" 0
  assert_raises "parse2 -c 5 -d" 0

  parse1 -a 3 -b
  parse2 -c 5 -d

  assert "echo ${cmdarg_cfg[c]}" "5"
  assert "echo ${cmdarg_cfg[d]}" "true"
  {
    set +u
    assert "${cmdarg_cfg[a]}" ""
    assert "${cmdarg_cfg[b]}" ""
  }

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

test_210_2_clean_state () {
  # Tests that cmdarg_purge ensures an empty config state.
  function parse1 () {
    cmdarg 'a:' 'a' 'some arg'
    cmdarg 'b' 'b' 'some arg'
    cmdarg_parse "$@"
  }

  function parse2 () {
    cmdarg_purge
    if [[ "$BASH_VERSION" == "4.0."* ]]; then
      # Bash 4.0 bug causes empty "$@" to be treated as an error with set -u
      cmdarg_parse
    else
      cmdarg_parse "$@"
    fi
  }

  cmdarg_purge

  assert_raises "parse1 -a 3 -b" 0
  assert_raises "parse2" 0

  parse1 -a 3 -b
  parse2

  assert "${cmdarg_cfg[a]:-}" ""

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

test_210_3_clean_state_subshells () {
  # Ensures that, when subsequent cmdarg invocations occur in subshells,
  # that the initial state is empty even without having called cmdarg_purge.

  cmdarg_purge

  function parse1 () {
    cmdarg 'a:' 'a' 'some arg'
    cmdarg 'b' 'b' 'some arg'
    cmdarg_parse "$@"
  }

  function parse2 () {
    if [[ "$BASH_VERSION" == "4.0."* ]]; then
      # Bash 4.0 bug causes empty "$@" to be treated as an error with set -u
      cmdarg_parse
    else
      cmdarg_parse "$@"
    fi
  }

  (parse1 -a 3 -b)
  (parse2)

  {
    set +u
    assert "echo ${cmdarg_cfg[a]}" ""
  }

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

