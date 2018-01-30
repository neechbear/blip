#!/bin/bash
# shellcheck disable=SC2034

test_240_1_usage_helper () {
  function usage_helper () {
    echo "LOL I AM A HELPER"
    return 0
  }

  function parser () {
    cmdarg_purge
    # shellcheck disable=SC2154
    cmdarg_helpers[usage]=usage_helper
    cmdarg_parse --help
  }

  assert "parser 2>&1" "LOL I AM A HELPER"

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

test_240_2_custom_helpers () {
  function always_succeed () {
    return 0
  }

  function describe () {
    declare longopt="${1:-}"
    declare opt="${2:-}"
    declare argtype="${3:-}"
    declare default="${4:-}"
    declare description="${5:-}"
    declare flags="${6:-}"
    declare validator="${7:-}"
    echo "${opt}:${longopt}:${argtype}:${description}:${default}:${flags}:${validator}"
  }

  function parser () {
    declare -a array=()
    declare -A hash=()
    cmdarg 's:' 'string' 'some string' '12345' always_succeed
    cmdarg 'b' 'boolean' 'some boolean'
    cmdarg 'a?[]' 'array' 'some array'
    cmdarg 'H?{}' 'hash' 'some hash'
    cmdarg_parse
  }

  cmdarg_purge
  # shellcheck disable=SC2154
  cmdarg_helpers['describe']=describe
  parser

  assert "cmdarg_describe s" "s:string:${CMDARG_TYPE_STRING}:some string:12345:${CMDARG_FLAG_REQARG}:always_succeed"
  assert "cmdarg_describe b" "b:boolean:${CMDARG_TYPE_BOOLEAN}:some boolean::${CMDARG_FLAG_NOARG}:"
  assert "cmdarg_describe a" "a:array:${CMDARG_TYPE_ARRAY}:some array::${CMDARG_FLAG_OPTARG}:"
  assert "cmdarg_describe H" "H:hash:${CMDARG_TYPE_HASH}:some hash::${CMDARG_FLAG_OPTARG}:"

  function usage () {
    echo "I ignore the default header and footer, and substitute my own."
    echo "I do not indent my arguments or separate optional and required."

    # cmdarg helpfully separates options into OPTIONAL or REQUIRED arrays
    # so that you don't have to sort the keys for uniform --help message output
    # and so you can easily break arguments out into required/optional blocks
    # in the usage message ... our helper doesn't care, it just prints them all
    # together, but it still uses the sorted lists.

    for shortopt in ${CMDARG_OPTIONAL[@]:-} ${CMDARG_REQUIRED[@]:-}
    do
      cmdarg_describe "$shortopt"
    done
  }

  declare output="I ignore the default header and footer, and substitute my own.
I do not indent my arguments or separate optional and required.
h:help:4:Show this help::0:
s:string:${CMDARG_TYPE_STRING}:some string:12345:${CMDARG_FLAG_REQARG}:always_succeed
b:boolean:${CMDARG_TYPE_BOOLEAN}:some boolean::${CMDARG_FLAG_NOARG}:
a:array:${CMDARG_TYPE_ARRAY}:some array::${CMDARG_FLAG_OPTARG}:
H:hash:${CMDARG_TYPE_HASH}:some hash::${CMDARG_FLAG_OPTARG}:"

  cmdarg_purge
  cmdarg_helpers['describe']=describe
  cmdarg_helpers['usage']=usage
  parser

  assert "cmdarg_parse --help 2>&1" "$output"

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

