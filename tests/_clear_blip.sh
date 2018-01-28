#!/bin/bash
_clear_blip () {
  #while read -r _ _ var_stmt ; do
  declare var=""
  while read -r var ; do
    #declare -x var="${var_stmt%%=*}"
    if [[ "$var" =~ ^(cmdarg|CMDARG|__BLIP|BLIP|ANSI)_.*$ \
       || "$var" == "CMDARG" ]] ; then
      echo "Unsetting $var"
      unset "$var"
    fi
  done < <(compgen -v)
  #done < <(typeset -x)
}
export -f _clear_blip
