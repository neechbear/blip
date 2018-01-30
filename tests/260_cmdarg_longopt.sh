#!/bin/bash
# shellcheck disable=SC2034,SC2154

test_260_1_longopt () {
  cmdarg_purge

  cmdarg 'l:' 'long-required-opt' 'Some long opt that requires a value'
  cmdarg 'o' 'long-boolean-opt' 'Some long option that is boolean'
  cmdarg 'L:' 'long-required-default-opt' 'Some long opt that requires a value but has a default' '(nil)'

  cmdarg_parse --long-required-opt hooha --long-boolean-opt

  assert "echo '${cmdarg_cfg[long-required-opt]}'" "hooha"
  assert "echo '${cmdarg_cfg[long-boolean-opt]}'" "true"
  assert "echo '${cmdarg_cfg[long-required-default-opt]}'" "(nil)"

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

test_260_2_longopt_shortopts_still_work () {
  cmdarg_purge

  cmdarg 'l:' 'long-required-opt' 'Some long opt that requires a value'
  cmdarg 'o' 'long-boolean-opt' 'Some long option that is boolean'
  cmdarg 'L:' 'long-required-default-opt' 'Some long opt that requires a value but has a default' '(nil)'

  cmdarg_parse -l hooha -o

  assert "echo '${cmdarg_cfg[long-required-opt]}'" "hooha"
  assert "echo '${cmdarg_cfg[long-boolean-opt]}'" "true"
  assert "echo '${cmdarg_cfg[long-required-default-opt]}'" "(nil)"

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

test_260_3_longopt_usage_messages () {
  cmdarg_purge
  cmdarg 'l:' 'long-required-opt' 'Some long opt that requires a value'
  assert "cmdarg_parse -h 2>&1 | grep long-required-opt" \
    " -l, --long-required-opt=VALUE : String. Some long opt that requires a value."

  cmdarg_purge
  cmdarg 'l' 'long-boolean-opt' 'Some long boolean opt'
  assert "cmdarg_parse -h 2>&1 | grep long-boolean-opt" \
    " -l, --long-boolean-opt : Boolean. Some long boolean opt."

  cmdarg_purge
  declare -a long_array_opt=()
  cmdarg 'l:[]' 'long_array_opt' 'Some long array opt'
  assert "cmdarg_parse -h 2>&1 | grep long_array_opt" \
    " -l, --long_array_opt=VALUE : Array. Some long array opt. (See note)"

  cmdarg_purge
  declare -A long_hash_opt=()
  cmdarg 'l:{}' 'long_hash_opt' 'Some long hash opt'
  assert "cmdarg_parse -h 2>&1 | grep long_hash_opt" \
    " -l, --long_hash_opt KEY=VALUE : Hash. Some long hash opt. (See note)"

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

