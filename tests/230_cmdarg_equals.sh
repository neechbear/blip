#!/bin/bash

test_230_1_equals_parsing_shortopt () {
  cmdarg_purge

  cmdarg 'x:' 'example' 'just an example'
  cmdarg_parse -x=133742

  # shellcheck disable=SC2154
  assert "echo '${cmdarg_cfg[example]}'" "133742"

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

test_230_2_equals_parsing_longopt () {
  cmdarg_purge

  cmdarg 'x:' 'example' 'just an example'
  cmdarg_parse --example=133742

  # shellcheck disable=SC2154
  assert "echo '${cmdarg_cfg[example]}'" "133742"

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

