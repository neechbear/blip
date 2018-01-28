#!/bin/bash

set -uo pipefail
shopt -s extglob
shopt -s nullglob

__bash_set="$-"

source "${BASH_SOURCE[0]%/*}/assert.sh"
source "${BASH_SOURCE[0]%/*}/../blip.bash"
source "${BASH_SOURCE[0]%/*}/_clear_blip.sh"

# Source all of the unit test shell scripts.
for test_file in "${BASH_SOURCE[0]%/*}"/+([0-9])[_-]*.sh
do
    source "$test_file"
done

# Run all of the unit test functions.
while read -r test_func
do
    $test_func "$@"
    set +xvEe
    eval "set -${__bash_set}"
done < <(compgen -A function | egrep '^test_[0-9]+_' | sort -n)

