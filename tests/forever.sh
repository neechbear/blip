#!/bin/bash

# https://github.com/neovim/neovim/issues/3460
# https://nicolaw.uk/ExecuteCommandOnFileChange

if [[ -z "${TESTONLY:-}" ]]; then
  TESTONLY=1
fi

while read -r directory events filename
do
  echo "$events ${directory%/}/$filename"
  sleep 2
  printf "\n"
  if [[ -x "${BASH_SOURCE[0]%/*}"/../build.sh ]]; then
    TESTONLY="$TESTONLY" "${BASH_SOURCE[0]%/*}"/../build.sh
  else
    "${BASH_SOURCE[0]%/*}"/tests.sh
  fi
  printf "\n\n"
done < <( inotifywait \
    -r -m -e close_write \
    --exclude '(/\.|~$|4913)' \
    "${BASH_SOURCE[0]%/*}" "${BASH_SOURCE[0]%/*}"/../blip.bash* )

