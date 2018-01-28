#!/bin/bash

test_280_1_validator_for_hash () {
  function my_hash_validator () {
    value="${1:-}"
    [[ "$value" == "my expected valueHash" ]]
  }
    
  declare -A something=()
    
  cmdarg_purge

  assert_raises "cmdarg 'x:{}' 'something' 'something' '' my_hash_validator" 0
  cmdarg 'x:{}' 'something' 'something' '' my_hash_validator

  assert_raises "cmdarg_parse --something key=entirelydifferent" 1
  assert_raises "cmdarg_parse --something 'key=my expected valueHash'" 0

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

test_280_2_validator_for_array () {
  function my_array_validator () {
    value="${1:-}"
    [[ "$value" == "my expected valueArray" ]]
  }
    
  declare -a something=()
    
  cmdarg_purge

  assert_raises "cmdarg 'x:[]' 'something' 'something' '' my_array_validator" 0
  cmdarg 'x:[]' 'something' 'something' '' my_array_validator

  assert_raises "cmdarg_parse --something entirelydifferent" 1
  assert_raises "cmdarg_parse --something 'my expected valueArray'" 0

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

test_280_3_validator_failure_recognized () {
  function my_validator () {
    value="${1:-}"
    [[ "$value" == "my expected valueString" ]]
  }
    
  cmdarg_purge

  assert_raises "cmdarg 'x:' 'something' 'something' '' my_validator" 0
  cmdarg 'x:' 'something' 'something' '' my_validator

  assert_raises "cmdarg_parse --something entirelydifferent" 1
  assert_raises "cmdarg_parse --something 'my expected valueString'" 0

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

