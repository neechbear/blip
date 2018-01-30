#!/bin/bash
# shellcheck disable=SC1091

set -euo pipefail
source /usr/lib/blip.bash

main () {
    declare -x name=""
    name="$(get_gecos_name)"
    if get_user_confirmation "Is your name $name?" ; then
        echo "Nice to meet you $name."
    else
        echo "I'll just call you $(get_username) then."
    fi
}

main "$@"

