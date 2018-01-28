#!/bin/bash

test_220_1_dashdash () {
  ###
  cmdarg_purge
  cmdarg_parse -- lolzors something
  assert_raises "cmdarg_parse -- lolzors something" 0

  assert 'echo "${cmdarg_argv[0]}"' "lolzors"
  assert 'echo "${cmdarg_argv[1]}"' "something"

  ###
  cmdarg_purge
  assert_raises "cmdarg_parse --lolzors" 1

  ###
  cmdarg_purge
  cmdarg 'x' 'xray' 'thingy for xray'

  cmdarg_parse -x lolzors
  assert_raises "cmdarg_parse -x lolzors" 0
  assert 'echo "${cmdarg_argv[0]}"' "lolzors"

  ###
  cmdarg_purge
  cmdarg 'x' 'xray' 'thingy for xray'

  cmdarg_parse -x -- lolzors
  assert_raises "cmdarg_parse -x -- lolzors" 0
  assert 'echo "${cmdarg_argv[0]}"' "lolzors"

  ###
  cmdarg_purge
  cmdarg 'x' 'xray' 'thingy for xray'
  cmdarg 'z?' 'zray' 'zray vision'

  cmdarg_parse -x -z yesplease lolzors
  assert_raises "cmdarg_parse -x -z yesplease lolzors" 0

  assert 'echo "${cmdarg_cfg[xray]}"' "true"
  assert 'echo "${cmdarg_cfg[zray]}"' "yesplease"
  assert 'echo "${cmdarg_argv[0]}"' "lolzors"
  assert 'echo "${cmdarg_argv[@]}"' "lolzors"
  assert 'echo "${#cmdarg_argv[@]}"' "1"

  ###
  cmdarg_purge
  cmdarg 'x' 'xray' 'thingy for xray'
  cmdarg 'z?' 'zray' 'zray vision'

  cmdarg_parse -x -- -z yesplease lolzors
  assert_raises "cmdarg_parse -x -- -z yesplease lolzors" 0

  assert 'echo "${cmdarg_cfg[xray]}"' "true"
  assert 'echo "${cmdarg_cfg[zray]}"' ""
  assert 'echo "${cmdarg_argv[0]}"' "-z"
  assert 'echo "${cmdarg_argv[1]}"' "yesplease"
  assert 'echo "${cmdarg_argv[2]}"' "lolzors"
  assert 'echo "${cmdarg_argv[@]}"' "-z yesplease lolzors"
  assert 'echo "${#cmdarg_argv[@]}"' "3"

  ###
  cmdarg_purge
  cmdarg 'x:' 'xray' 'thingy for xray'

  cmdarg_parse -x -- lolzors
  assert_raises "cmdarg_parse -x -- lolzors" 0

  assert 'echo "${cmdarg_cfg[xray]}"' "--"
  assert 'echo "${cmdarg_argv[0]}"' "lolzors"
  assert 'echo "${cmdarg_argv[@]}"' "lolzors"
  assert 'echo "${#cmdarg_argv[@]}"' "1"

  assert_end "${BASH_SOURCE[0]##*/}:${FUNCNAME[0]}()"
}

