blip.bash 3 "August 2018" blip.bash "Bash Library for Indolent Programmers"
===========================================================================

# NAME

blip.bash - Bash Library for Indolent Programmers 

# SYNOPSIS

    #!/bin/bash
    
    set -euo pipefail
    source /usr/lib/blip.bash
    
    main () {
        local name="$(get_gecos_name)"
        if get_user_confirmation "Is your name ${name:-(unknown)}?" ; then
            echo "Nice to meet you ${name:-mystery user}."
        else
            echo "I'll just call you $(get_username) then."
        fi
    }
    
    main "$@"

# DESCRIPTION

**blip** is a Bash Library for Indolent (lazy) Programmers. It is a bash script
that is intended to be sourced in as a library of common functions to aid 
development of shell scripts.

This project is still in the early stages of development and is expected to
change. However, with the mantra release early, release often, in mind, it is
available in this early state to help solicit feedback and user input.

Please feel free to contact the author or offer patches to the source.

# FUNCTIONS

## abs ()

## absolute ()

Alias for `abs ()`.

## is_mac_address ()

## is_eui48_address ()

## is_eui64_address ()

## read_config_file ()

## trim ()

## is_newer_version ()

## required_command_version ()

## append_trap "$ACTION" "$SIGNALn" ...

## execute_trap_stack "$SIGNAL"

## get_trap_stack "$SIGNALn" ...

## pop_trap_stack "$SIGNALn" ...

## push_trap_stack "$ACTION" "$SIGNALn" ...

## set_trap_stack "$ACTION" "$SIGNALn" ...

## unset_trap_stack "$SIGNALn" ...

## append_if_not_present ()

## get_pid_lock_filename "$LOCK_DIR" "$PID_FILENAME"

## get_exclusive_execution_lock ()

## get_date ()

## get_file_age "$FILE"

## get_free_disk_space "$FILESYSTEM"

## get_fs_mounts ()

## get_gecos_info ()

## get_gecos_name ()

## get_user_shell ()

## get_max_length ()

## get_string_characters ()

## get_unixtime ()

## get_user_confirmation ()

See also: `select` bash built-in.

## get_username ()

## get_user_selection ()

See also: `select` bash built-in.

## as_json_string ()

## as_json_value ()

## get_variable_type ()

## vars_as_json ()

## is_abs_int ()

## is_absolute_integer ()

Alias for `is_abs_int ()`.

## is_boolean ()

## is_false "$ARG1"

Return `0` (*true*) if `$ARG1` may be considered boolean false by a human.
Values to be considered true include: `0`, `false`, `no`, `off`, `disable` and
`disabled`.

## is_in_path "$CMDn" ...

## is_float "$ARG1"

Return `0` (*true*) if `$ARG1` is a floating-point value.

## is_int "$ARG1"

Return `0` (*true*) if `$ARG1` is an integer value.

## is_integer "$ARG1"

Alias for `is_int ()`.

## is_zero "$ARG1"

## is_negative "$ARG1"

## is_positive "$ARG1"

## is_true "$ARG1"

Return `0` (*true*) if `$ARG1` may be considered boolean true by a human.
Values to be considered true include: `1`, `true`, `yes`, `on`, `enable` and
`enabled`.

## is_word_in_string "$STR1" "$WORD1"

## to_lower "$ARGn" ...

## to_upper "$ARGn" ...

## url_exists "$URL"

Return `0` (*true*) if `$URL` exists, as determined by a 2XX HTTP response
code. Otherwise returns `1` (*false*).

Requires the `curl` command to be present in the shell search path.

## url_http_header "$URL"

Outputs (echos to `STDOUT`) the full HTTP response headers returned by the
remote web server for `$URL`.

Requires the `curl` command to be present in the shell search path.

## url_http_response "$URL"

Outputs (echos to `STDOUT`) the HTTP response code (including textual 
description) returned by the remote web server for `$URL`. Follows HTTP
redirects using `curl`'s `-L` flag, returning only the last HTTP response code.

Requires the `curl` command to be present in the shell search path.

## url_http_response_code "$URL"

Similar to `url_http_response`, except the textual description is omitted,
outputting only the numerical value.

## cmdarg_info "$TYPE" "$ARGn" ...

See *COMMAND LINE ARGUMENT PARSING*.

## cmdarg "$FLAG" "$LONGOPT" "$DEFALT" "$VALIDATOR"

See *COMMAND LINE ARGUMENT PARSING*.

## cmdarg_parse "$@"

See *COMMAND LINE ARGUMENT PARSING*.

## cmdarg_usage ()

See *COMMAND LINE ARGUMENT PARSING*.

## cmdarg_describe "$FLAG"

See *COMMAND LINE ARGUMENT PARSING*.

## cmdarg_purge ()

See *COMMAND LINE ARGUMENT PARSING*.

## cmdarg_check_empty "$FLAG"

Used internally by command line argument parsing (`cmdarg_parse()` function),
not usually expected to be used directly. See *COMMAND LINE ARGUMENT PARSING*.

## cmdarg_describe_default ...

Used internally by command line argument parsing (`cmdarg_describe()`
function), not usually expected to be used directly. See
*COMMAND LINE ARGUMENT PARSING*.

## cmdarg_set_opt "$LONGOPT" "$VALUE"

Used internally by command line argument parsing (`cmdarg_parse()` function),
not usually expected to be used directly. See *COMMAND LINE ARGUMENT PARSING*.

## cmdarg_validate ...

Used internally by command line argument parsing (`cmdarg_set_opt()` function),
not usually expected to be used directly. See *COMMAND LINE ARGUMENT PARSING*.

# COMMAND LINE ARGUMENT PARSING

Documentation relating to command line argument parsing can be found in the
`blip.bash(7)` man page. It can also be viewed online in the
[CMDARG.md](CMDARG.md) file at
[https://github.com/neechbear/blip/blob/master/CMDARG.md](https://github.com/neechbear/blip/blob/master/CMDARG.md).

# VARIABLES

## BLIP_VERSION

Contains the version of **blip** as a string value.

Example: `0.01-3-prerelease`

## BLIP_VERSINFO

A 4-element array containing version information about the version of **blip**.

Example:

    BLIP_VERSINFO[0] = 0          # Major version number
    BLIP_VERSINFO[1] = 01         # Minor version number
    BLIP_VERSINFO[2] = 3          # Patch / release number
    BLIP_VERSINFO[3] = prerelease # Release status

## BLIP_START_UNIXTIME

## BLIP_TRAP_MAP

## BLIP_TRAP_STACK

## ANSI, & ANSI_*

These variables contain common ANSI terminal colour codes.

A list of all keys within the `ANSI` associative array may be obtained through
the following code example:

    BLIP_ANSI_VARIABLES=1
    source /usr/lib/blip.bash
    echo "${!ANSI[@]}"

See also *BLIP_ANSI_VARIABLES* in the *ENVIRONMENT* section below.

## cmdarg_cfg

See *COMMAND LINE ARGUMENT PARSING*.

## cmdarg_argv

See *COMMAND LINE ARGUMENT PARSING*.

## cmdarg_helpers

See *COMMAND LINE ARGUMENT PARSING*.

## CMDARG, CMDARG_*

The following variables are used internally by the command line argument
parsing: `CMDARG`, `CMDARG_REV`, `CMDARG_OPTIONAL`, `CMDARG_REQUIRED`,
`CMDARG_DESC`, `CMDARG_DEFAULT`, `CMDARG_VALIDATORS`, `CMDARG_INFO`,
`CMDARG_FLAGS`, `CMDARG_TYPES`.

These variables are not intended to be read or modified directly.

See *COMMAND LINE ARGUMENT PARSING*.

# ENVIRONMENT

## BLIP_DEBUG_LOGLEVEL

## BLIP_ALLOW_FOREIGN_SHELLS

When set to `1`, inhibits `exit` functionality to abort operation
when **blip** determines that it is not running inside a bash shell interpreter.

See also *BLIP_INTERNAL_FATAL_ACTION*.

## BLIP_INTERNAL_FATAL_ACTION

Specifies the command to execute when `blip` encounters a fatal internal
condition such as being called by an incompatible foreign shell, or not meeting
the minimum version requirements set by the `BLIP_REQUIRE_VERSION` variable.

Defaults to `exit 2`.

See also: *BLIP_REQUIRE_VERSION*.

## BLIP_REQUIRE_VERSION

Specifies the minimum version of **blip** required by the calling parent script.
**blip** will `exit` with a non-zero (`2`) return code if the
`${BLIP_VERSINFO[@]}` array does not indicate a version that is equal to
or greater.

Example:

    BLIP_REQUIRE_VERSION="0.02-13"
    source /usr/lib/blip.bash

## BLIP_ANSI_VARIABLES

When set to `1`, causes **blip** to declare read-only variables containing
common ANSI terminal colour codes. All declared variable names being with
the prefix `ANSI_`, with the excption of one associative array which is
simply `ANSI`.

A list of all declared ANSI variables may be obtained through the following
code example:

    BLIP_ANSI_VARIABLES=1
    source /usr/lib/blip.bash
    compgen -A variable | grep ANSI

See also: [https://en.wikipedia.org/wiki/ANSI_escape_code](https://en.wikipedia.org/wiki/ANSI_escape_code).

## BLIP_EXTERNAL_CMD_FLOCK

Specifies an explicit command path when executing the external dependency
command `flock`. Defaults to `flock` without an explicit path in order to
search `$PATH`.

## BLIP_EXTERNAL_CMD_STAT

Specifies an explicit command path when executing the external dependency
command `stat`. Defaults to `stat` without an explicit path in order to
search `$PATH`.

## BLIP_EXTERNAL_CMD_BC

Specifies an explicit command path when executing the external dependency
command `bc`. Defaults to `bc` without an explicit path in order to
search `$PATH`.

## BLIP_EXTERNAL_CMD_CURL

Specifies an explicit command path when executing the external dependency
command `curl`. Defaults to `curl` without an explicit path in order to
search `$PATH`.

## BLIP_EXTERNAL_CMD_DATE

Specifies an explicit command path when executing the external dependency
command `date`. Defaults to `date` without an explicit path in order to
search `$PATH`.

## BLIP_EXTERNAL_CMD_GREP

Specifies an explicit command path when executing the external dependency
command `grep`. Defaults to `grep` without an explicit path in order to
search `$PATH`.

# AUTHOR

Nicola Worthington (nicola@tfb.net).

# URLS

[https://nicolaw.uk/blip](https://nicolaw.uk/blip),
[https://github.com/neechbear/blip/](https://github.com/neechbear/blip/).

# SEE ALSO

/usr/share/doc/blip, bash(1), blip.bash(7).

# COPYRIGHT

Copyright (c) 2016,2017 Nicola Worthington (nicolaw@tfb.net).
With contributions from Sergej Alikov, 2016.

Command line argument parsing functionality is adapted from the `cmdarg.sh`
library ([ttps://github.com/akesterson/cmdarg](ttps://github.com/akesterson/cmdarg)),
which is written by and Copyright (c) 2013 Andrew Kesterson (andrew@aklabs.net).

This software is released under the MIT License.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

