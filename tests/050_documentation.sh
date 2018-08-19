#!/bin/bash

test_050_documentation () {
  declare blip="${BASH_SOURCE[0]%/*}/../blip.bash"
  declare md="${blip}.3.md"
  declare man3="${blip}.3"

  # Check all functions are documented.
  while read -r function ; do
    function="${function%% *}"
    assert_raises "grep '^## $function ' '$md'" 0
  done < <(grep -Eo '^[a-z_]+\ \(\)' "$blip" | sort -u)

  # Check all BLIP_ variables are documented.
  while read -r variable ; do
    assert_raises "grep -w '^## $variable' '$md'" 0
  done < <(compgen -v | grep ^BLIP_)

  # Check blip(3) man page is a similar age to the markdown.
  declare -i md_age
  declare -i man3_age
  # shellcheck disable=SC2034
  md_age="$(get_file_age "$md")"
  assert "echo $?" 0
  # shellcheck disable=SC2034
  man3_age="$(get_file_age "$man3")"
  assert "echo $?" 0
  # shellcheck disable=SC2016
  assert_raises '[[ $(( man3_age - md_age )) -le 60 ]]' 0

  assert_end "${BASH_SOURCE[0]##*/}"
}

