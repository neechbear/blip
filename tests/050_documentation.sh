#!/bin/bash

test_050_documentation () {
  declare blip="${BASH_SOURCE[0]%/*}/../blip.bash"
  declare pod="${blip}.pod"
  declare man3="${blip}.3"

  # Check all functions are documented.
  while read -r function ; do
    function="${function%% *}"
    assert_raises "grep '^=head2 $function ' '$pod'" 0
  done < <(egrep -o '^[a-z_]+\ \(\)' "$blip" | sort -u)

  # Check all BLIP_ variables are documented.
  while read -r variable ; do
    assert_raises "grep -w '^=head2 $variable' '$pod'" 0
  done < <(compgen -v | grep ^BLIP_)

  # Check blip(3) man page is a similar age to the pod.
  declare -i pod_age
  declare -i man3_age
  # shellcheck disable=SC2034
  pod_age="$(get_file_age "$pod")"
  assert "echo $?" 0
  # shellcheck disable=SC2034
  man3_age="$(get_file_age "$man3")"
  assert "echo $?" 0
  # shellcheck disable=SC2016
  assert_raises '[[ $(( man3_age - pod_age )) -le 60 ]]' 0

  assert_end "${BASH_SOURCE[0]##*/}"
}

