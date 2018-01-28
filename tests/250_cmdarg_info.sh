#!/bin/bash

test_250_1_info_reject_invalid () {
  cmdarg_purge

  assert_raises "cmdarg_info INVALID_SECTION" 1

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

test_250_2_info_accept_valid () {
  cmdarg_purge

  declare type=""
  for type in header version footer author copyright
  do 
    assert_raises "cmdarg_info '$type' 'ZYX Some $type from the info 123'" 0
    cmdarg_info "$type" "ZYX Some $type from the info 123"
    assert_raises "cmdarg_parse --help 2>&1 | grep 'ZYX Some $type from the info 123'" 0
  done


  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

