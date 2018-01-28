#!/bin/bash

test_270_1_flags_required () {
  # Tests that flags (:?) are required for array or hash arguments
    
  cmdarg_purge
  declare -a something=()
  declare -A something_else=()
  assert_raises "cmdarg 'x[]' 'something' 'something'" 1
  assert_raises "cmdarg 'y{}' 'something_else' 'something else'" 1

  cmdarg_purge
  assert_raises "cmdarg 'x:[]' 'something' 'something'" 0
  assert_raises "cmdarg 'y:{}' 'something_else' 'something'" 0

  cmdarg_purge
  assert_raises "cmdarg 'x?[]' 'something' 'something'" 0
  assert_raises "cmdarg 'y?{}' 'something_else' 'something'" 0

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

test_270_2_array_undefined () {
  # Tests that cmdarg and cmdarg_parse return an error when an array
  # is undefined
  cmdarg_purge
  assert_raises "cmdarg 'a:[]' 'missingarray'" 1
  assert "cmdarg 'a:[]' 'missingarray' 2>&1 >/dev/null | grep 'declare variable first'" \
    'Array variable "missingarray" does not exist; array arguments must declare variable first.'

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

test_270_3_array_values () {
  cmdarg_purge

  declare -a array=()
  cmdarg 'a:[]' 'array'

  assert_raises "cmdarg_parse -a a -a b -a c" 0
  cmdarg_parse -a a -a b -a c

  assert 'echo "${array[1]:-}"' "a"
  assert 'echo "${array[2]:-}"' "b"
  assert 'echo "${array[3]:-}"' "c"
  assert 'echo "${#array[@]}"' "3"
  assert 'echo "${array[@]:-}"' "a b c"
  assert 'echo "${!array[@]}"' "1 2 3"

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

test_270_4_hash_undefined () {
  # Tests that cmdarg and cmdarg_parse return an error when an array
  # is undefined
  cmdarg_purge
  assert_raises "cmdarg 'a:{}' 'missinghash'" 1
  assert "cmdarg 'a:{}' 'missinghash' 2>&1 >/dev/null | grep 'declare variable first'" \
    'Associative array variable "missinghash" does not exist; hash arguments must declare variable first.'

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

test_270_5_hash_values () {
  cmdarg_purge

  declare -A hash=()
  cmdarg 'H:{}' 'hash'

  assert_raises "cmdarg_parse -H a=11 -H b=22 -H c=33" 0
  cmdarg_parse -H a=11 -H b=22 -H c=33

  assert 'echo "${hash[a]:-}"' "11"
  assert 'echo "${hash[b]:-}"' "22"
  assert 'echo "${hash[c]:-}"' "33"
  assert 'echo "${hash[@]:-}"' "11 22 33"
  assert 'echo "${!hash[@]}"' "a b c"

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

test_270_6_boolean_no_optarg () {
  cmdarg_purge

  assert_raises "cmdarg 'b' 'boolean'" 0
  cmdarg 'b' 'boolean'

  assert_raises "cmdarg_parse -b something" 0
  cmdarg_parse -b something

  assert "echo ${cmdarg_cfg[boolean]}" "true"
  assert "echo ${cmdarg_argv[0]}" "something"

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

test_270_7_hash_malformed () {
  # Checks for malformed hash arguments that pass parsing.
  declare -A myhash=()
  function parse () {
    cmdarg_purge 
    cmdarg 'x:{}' 'myhash' 'myhash'
    cmdarg_parse "$@"
  }

  assert_raises "parse --myhash iamjustavalue" 1
  assert "parse --myhash iamjustavalue 2>&1 >/dev/null | head -n 2" \
    "Malformed hash argument: iamjustavalue"$'\n'"Missing 1 mandatory argument(s) : -x"

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

