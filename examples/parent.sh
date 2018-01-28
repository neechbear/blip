#!/bin/bash

set -ueo pipefail
export PS4='+ $$($BASHPID) +${SECONDS}s (${BASH_SOURCE[0]}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
for arg in "$@" ; do
    if [[ "$arg" = "--debug" ]] ; then
        set -xv; break
    fi
done

source "${BASH_SOURCE[0]%/*}/child.sh"

