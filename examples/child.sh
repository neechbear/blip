#!/bin/bash

if [[ -r blip.bash ]] ; then
    source blip.bash
elif [[ -r "${BASH_SOURCE[0]%/*}/../blip.bash" ]] ; then
    source "${BASH_SOURCE[0]%/*}/../blip.bash"
else
    source /usr/lib/blip.bash
fi

counter () {
  declare -i i
  for ((i=0; i<=4; i++)) ; do 
    echo "$(( $(printf '%(%s)T' -1) - $(printf '%(%s)T' -2) ))"
    sleep 0.6
  done
}

echo "Hello world!"

counter "$@"

declare -x foo="BAR MEH BLERG"
echo "Woop ${foo##* } ${BLIP_START_UNIXTIME}!"

