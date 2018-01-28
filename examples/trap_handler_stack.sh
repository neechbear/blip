#!/bin/bash

# This example shows you how you can use a stack of trap handlers.

set -euo pipefail

# shellcheck disable=SC2034
BLIP_ANSI_VARIABLES=1
# shellcheck disable=SC2034
BLIP_REQUIRE_VERSION="0.01-3"
# shellcheck disable=SC2034
BLIP_DEBUG_LOGLEVEL=3
source "${BASH_SOURCE[0]%/*}/../blip.bash"

push_trap_stack "echo 'hello world'" INT
push_trap_stack "echo 'foo bar'" INT HUP
push_trap_stack "echo 'this will not appear'" INT HUP
pop_trap_stack INT
get_trap_stack INT
set_trap_stack "echo 'woop woop'" INT
get_trap_stack INT
get_trap_stack HUP
unset_trap_stack HUP
get_trap_stack HUP
# shellcheck disable=SC2016
push_trap_stack 'for ((x=0; x<=10; x++)) ; do echo " >> x=$x << "; done' INT HUP
push_trap_stack "echo 'The final countdown.'" INT

echo "${ANSI[bold]}${ANSI[cyan]}Try pressing Control-C to trigger a SIGINT trap handler stack.${ANSI[reset]}"
for ((i=6; i>=0; i--)); do
    echo "$i"
    sleep 1
done
echo "${ANSI[bold]}${ANSI[red]}Too late; better luck next time!${ANSI[reset]}"

set_trap_stack "echo 'Interrupted by user input.'" INT
set_trap_stack "echo 'Interrupted by signal.'" HUP

