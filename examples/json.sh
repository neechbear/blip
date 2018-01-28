#!/bin/bash

set -euo pipefail

# shellcheck disable=SC2034
BLIP_REQUIRE_VERSION="0.4-1"
source "${BASH_SOURCE[0]%/*}/../blip.bash"

unset MYARRAY MYOBJECT MYBOOLEAN MYNULL MYSTRING MYNUMBER MYFLOAT \
  MYNULLARRAY MYNULLOBJECT

declare -i MYNUMBER=3
declare MYFLOAT=3.15
declare MYBOOLEAN=true
declare MYNULL=
declare -a MYNULLARRAY=
declare MYSTRING=" <This is a string!> "
declare -a MYARRAY=("index one" "" 3 "  four  " "")
declare -A MYNULLOBJECT=
declare -A MYOBJECT=([one]="index one" [two]= [three]=3 [four]="  four   " [five]="")
declare -p MYOBJECT

compgen -v MY

BLIP_DEBUG_LOGLEVEL=3
vars_as_json $(compgen -v MY)

