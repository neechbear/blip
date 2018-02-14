#!/usr/bin/env bash
# vim:ts=2:sw=2:tw=79

set -Eeuo pipefail
shopt -s extglob
shopt -s nocasematch
shopt -s extdebug

# Secure environment.
IFS=$' \t\n'
unset -f unalias
# shellcheck disable=SC1001
\unalias -a
unset -f command
if ! PATH="$(command -p getconf PATH 2>/dev/null)" && [[ -z "$PATH" ]]; then
  PATH="/usr/bin:/bin"
fi

# Load libraries.
if ! BLIP_REQUIRE_VERSION=0.9.1 PATH="$PATH:/usr/lib:$HOME/bin" source blip.bash
then
  >&2 echo "Missing dependency 'blip' (https://nicolaw.uk/blip); aborting!"
  exit 2
fi

# Report when we exited due to Bash errors.
exec 3>&1 4>&2
trap 'declare rc=$?;
      >&2 echo "Unexpected error executing $BASH_COMMAND at ${BASH_SOURCE[0]} line $LINENO";
      __blip_stacktrace__ >&2; exit $rc' ERR

_parse_command_line_arguments () {
  cmdarg_info "header" "Description of the script."
  cmdarg_info "author" "Nicola Worthington <nicolaw@tfb.net>."
  cmdarg_info "copyright" "(C) 2017 Copyright message."

  cmdarg_info "footer" \
    "For help configuring the command line arguments using blip.bash, see" \
    "https://github.com/neechbear/blip/blob/master/CMDARG.md."

  cmdarg 'm:'   'mandatory' 'Uber important mandatory argument'
  cmdarg 'f:[]' 'foo_list'  'A list of things you need'
  cmdarg 'o?'   'optional'  'Some optional argument'
  cmdarg 'b'    'boolean'   'Some boolean argument'
  cmdarg 'V'    'verbose'   'Display more verbose informational output'

  cmdarg_parse "$@" || return $?
}

main () {
  # Command line argument processing.
  # shellcheck disable=SC2034
  declare -r VERSION="0.0.1"
  declare -A cmdarg_cfg=()
  declare -a foo_list=()
  _parse_command_line_arguments "$@" 1>&3 2>&4 || exit $?

  if [[ -n "${cmdarg_cfg[verbose]}" || -n "${DEBUG:-}" ]] ; then
    for i in "${!cmdarg_cfg[@]}" ; do
      printf "\${cmdarg_cfg[%s]}=%q\n" "$i" "${cmdarg_cfg[$i]}"
    done
    for i in "${!foo_list[@]}" ; do
      printf "\${foo_list[%s]}=%q\n" "$i" "${foo_list[$i]}"
    done
  fi
  [[ -z "${cmdarg_cfg[help]:-}" ]] || return 0

  # Main script.
  declare -i rc=0
  echo stdout
  >&2 echo stderr

  return $rc
}

# Called as a command script (not sourced as a library).
if [[ "$(readlink "${BASH_SOURCE[0]}")" == "$(readlink "$0")" ]] ; then
  if ! is_true "${DEBUG:-}" ; then
    unset DEBUG
  else
    # Turn bash xtrace debugging on if $DEBUG environment is true.
    exec 19> "${TMPDIR:-/tmp}/${BASH_SOURCE[0]##*/}.xtrace.$$.log"
    { # Print debug header to xtrace log file.
      printf "Command line: \"%q\"" "$0" ; printf " \"%q\"" "$@" ; printf "\n"
      printf "\$-: %s\n" "$-"
      printf "BASHOPTS: %s\n" "$BASHOPTS"
      printf "SHELLOPTS: %s\n" "$SHELLOPTS"
      printf "Start time: %(%Y%m%d %H%M%S %z)T\n" -2
      if is_in_path "git" && [[ -d "${BASH_SOURCE[0]%/*}/.git" ]] ; then
        printf "Git revision: %s\n" \
          "$(git -C "${BASH_SOURCE[0]%/*}" rev-parse --verify HEAD 2>&1)"
      fi
      printf "Hostname: %s\n" "${HOSTNAME:-$(hostname -f 2>&1)}"
      printf "\n" ; env ; printf "\n"
    } >&19 2>&19
    export BASH_XTRACEFD=19
    export PS4='+ $$($BASHPID) +${SECONDS}s (${BASH_SOURCE[0]}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    set -vx
  fi

  # Logging to syslog, and console with process, PID and timestamp prefix.
  if is_in_path "logger" && is_in_path "ts" ; then
    exec > >( 2>&-; logger -s -t "${0##*/}[$$]" -p user.info  2>&1 \
            | ts "%d-%m-%y %X" | tee -ia "${0%.*}.log" ) \
        2> >( logger -s -t "${0##*/}[$$]" -p user.error 2>&1 \
            | ts "%d-%m-%y %X" | tee -ia "${0%.*}.log" >&2 )
    sleep 0.1
  fi

  # Call main application.
  main "$@"
fi

