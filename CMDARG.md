# Command Line Argument Parsing

Simple and convenient command line argument parsing library written entirly in,
and for, Bash version 4. Requires no external external commands, and thus
functions properly on any platform where Bash 4 can be installed.

Works safely with `nounset` (`set -u`), `functrace` (`set -T`), `xtrace`
(`set -x`) and `extdebug` options.

## Synopsis

    #!/bin/bash
    
    set -euo pipefail
    if ! source /usr/lib/blip.bash ; then
      >&2 echo "Missing dependency 'blip' (https://nicolaw.uk/blip); exiting!"
      exit 2
    fi
    
    _parse_command_line_arguments () {
      cmdarg_info "header" "Very important script, many awesome, much WOW!"
      cmdarg_info "version" "1.33.7"
    
      cmdarg_info "author" "Bigly Important Developer <mr.big@example.com>."
      cmdarg_info "copyright" "(C) 2017 Copyright ACME Example Corp EU SARL."
    
      cmdarg_info "footer" \
        "For help configuring the command line arguments using blip.bash, see" \
        "https://github.com/neechbear/blip/blob/master/CMDARG.md."
    
      cmdarg 'b'    'boolean'   'A funky boolean argument'
      cmdarg 'o?'   'optional'  'An awesome optional argument'
      cmdarg 'm:'   'mandatory' 'Uber important mandatory argument'
      cmdarg 'a:[]' 'foo_list'  'A list of things foo-ish things'
      cmdarg 'A:[]' 'bar_dict'  'A "dict" table of bar-like stuff'
    
      cmdarg_parse "$@" || return $?
    }
    
    main () {
      declare -gA cmdarg_cfg=()
      declare -ga foo_list=()
      declare -gA bar_dict=()
      _parse_command_line_arguments "$@" || exit $?
    
      if [[ -n "${cmdarg_cfg[verbose]}" || -n "${DEBUG:-}" ]] ; then
        for i in "${!cmdarg_cfg[@]}" ; do
          printf '${cmdarg_cfg[%s]}=%q\n' "$i" "${cmdarg_cfg[$i]}"
        done
        for i in "${!foo_list[@]}" ; do
          printf '${foo_list[%s]}=%q\n' "$i" "${foo_list[$i]}"
        done
        for i in "${!bar_dict[@]}" ; do
          printf '${bar_dict[%s]}=%q\n' "$i" "${bar_dict[$i]}"
        done
      fi
    
      return $rc
    }
    
    main "$@"

## Description

The `cmdarg` functionality of `blip.bash` is similar to the `getopt` and
`getopts` commands that allow you to break up (parse) options on a shell command
line for easy parsing by shell functions. It offers substantial benefits over
traditional `getopt` and `getopts` solutions, which include:

- Support for list options that can be specified multiple times on the command
  line, the values of which will be stored in to an array variable.

- Support for dictionary options that can allow key / value pairs to be
  specified on the command line, the values of which will be store in to an
  associative array (a.k.a. dictionary or hash) variable.

- Support for default values for options that are not explicitly specified on
  the command line.

- Support for validation of command line option values through the use of
  call-back function.

- Support for both short and long length option types (`-o|--options`).

- Built-in convenience command line help fuctionality through the use of the
  `-h` and `--help` command line options.

Currently, internals of `cmdarg` use the short option of easy option definition
as an internal key. This limits the number of usable option definitions to the
number of unique single characters in the ASCII character set, which is
realistically 62 options (26 upper-case characters, 26 lower-case characters,
10 digits).

Future releases will remove this restristion.

## Defining Help Information with cmdarg_info

This function sets up information about your program for use when printing the
help / usage message. The first argument passed to `cmdarg_info` should be one
of the following: `version`, `header`, `author`, `copyright` or `footer`.
The second to `n`th arguments are arbitary strings that should adequately
describe the first argument.

Use of `cmdarg_info` function is entirely optional.

If no `version` is defined through calling `cmdarg_info`, then the script
version number will be taken from the `$VERSION` variable if it is defined.

    cmdarg_info "version" "4.02 (stable)"
    cmdarg_info "header" "Short summary of what this script is." \
      "Can be multiple lines if you prefer to put a slightly longer command" \
      "overview or synopsis here."

    cmdarg_info "author" "Some Poor Bastard <somepoorbastard@hell.com>"
    cmdarg_info "copyright" "(C) 2017 Some Legal Entity."

    cmdarg_info "footer" "Some information to print after the help." \
                         "You can specify as many or as few lines as you like."

Output from the above example:

    $ your_script.sh --help
    your_script.sh version 4.02 (stable)
    (C) 2017 Some Legal Entity. : Some Poor Bastard <somepoorbastard@hell.com>
    
    Short summary of what this script is.
    Can be multiple lines if you prefer to put a slightly longer command
    overview or synopsis here.
    
    Optional arguments:
     -h, --help : Boolean. Show this help.
    
    Some information to print after the help.
    You can specify as many or as few lines as you like.

## Definig Options with cmdarg

This function is used to tell the library what command line arguments you accept.

    cmdarg FLAGS LONGOPT DESCRIPTION DEFAULT VALIDATOR

Examples:

    cmdarg 'f' 'boolean-flag' 'Some boolean flag'
    cmdarg 'a:' 'required-arg' 'Some required arg'
    cmdarg 'a?' 'optional-arg' 'Some optional arg with a default' 'default_value'
    cmdarg 'a:' 'required-validated-arg' 'Some required argument with a validator' '' validator_function

### FLAGS

The first argument to cmdarg must be an argument specification. Argument
specifications take the form 'NOT', where:

- *N* : The single letter Name of the argument.

- *O* : Whether the option is optional or not. Use `:` here for a required
        argument, `?` for an optional argument. If you provide a default
        value for a required argument (:), then it becomes optional.

- *T* : The type. Leave empty for a string argument, use `[]` for an array
        argument, use `{}` for a hash argument.

If *O* and *T* are both unset, and only the single letter *N* is provided, then
the argument is a boolean argument which will default to false.

### LONGOPT

The long command line option name (such as long-option-name) that can be used
to set your argument via `--LONGOPT` instead of via `-N` (from your FLAGS).

### DESCRIPTION

The string that describes what this argument is for.

### DEFAULT

Any default value that you want to be set for this option if the user does not
specify one.

### VALIDATOR

The name of a bash function which will validate this argument (see VALIDATORS
section below).

## List (Array) & Dict (Associative Array) Options

When using list and dict options, there must be an array or associative array
pre-declared before definit the option with the `cmdarg` function. Failure to
do so will result in an error message being printed to `STDERR`, and
`$CMDARG_ERROR_BEHAVIOR` being executed (which will `return 1` by default).

A list of values can be stored in an array through the use of the `[]` modifier
on the short option given to `cmdarg`.

    declare -a recipients=()
    cmdarg 'r?[]' 'recipients' 'Recipient email address(es)'
    cmdarg_parse "$@"
    for i in "${!recipients[@]}" ; do
      printf 'recpipients[%d]=%q\n' "$i" "${recipients[$i]}"
    done

When executed, should produce the following output:

    $  your_script.sh -r jack@example.com -r jill@example.com \
                      --recipients=kings.horses@example.com \
                      -r kings.men@example.example.com
    recpipients[1]=jack@example.com
    recpipients[2]=jill@example.com
    recpipients[3]=kings.horses@example.com
    recpipients[4]=kings.men@example.com

A dictionary or table of values can be stored in an associative array through
the use of the `{}` modifier on the short option given to `cmdarg`.

    declare -A animal_phylum=()
    cmdarg 'A?{}' 'animal_phylum' 'Animal to phylum mapping'
    cmdarg_parse "$@"
    for k in "${!animal_phylum[@]}" ; do
      printf 'animal_phylum[%q]=%q\n' "$k" "${animal_phylum[$k]}"
    done

When executed, should produce the following output:

    $ your_script.sh -A carp=actinopterygii -A panda=mammalia \
                     --animal_class human=mammalia
    animal_class[panda]=mammalia
    animal_class[carp]=actinopterygii
    animal_class[human]=mammalia

### Validators

Validators must be bash function names - not bash statements - and they must
accept one argument, being the value to validate. Validators are not told the
name of the option, only the value. Validator functions must return 0 if they
value they are given is valid, and 1 if it is invalid. Validators should refrain
from producing output on stdout or stderr.

For example, this is a valid validator:

    function validate_int
    {
        if [[ "$1" =~ ^[0-9]+$ ]] ; then
            return 0
        fi
        return 1
    }

    cmdarg 'x' 'x-option' 'some opt' '' validate_int

While this is not:

    cmdarg 'x' 'x-option' 'some opt' '' "grep -E '^[0-9]+$'"

There is an exception to this form, and that is for hash arguments (e.g. 'x:{}').
In this instance, the key for the argument (e.g. -x key=value) is to be
considered a part of the value, and the user may want to validate this as well as
the value. In this instance, when calling a validator against a hash argument,
the validator will receive a second argument, which is the key of the hash being
validated. For example:

    # When we receive
    cmdarg 'x:{}' 'something' 'something' my_validator
    cmdarg_parse -x hashkey=hashvalue
    # ... we will call
    my_validator hashvalue hashkey

## Parsing the Command Line with cmdarg_parse

This command does what you expect, parsing your command line arguments. However
you must pass your command line arguments to it. Generally this means:

    cmdarg_parse "$@"

Beware that `$@` will change depending on your context. So if you have a
main() function called in your script, you need to make sure that you pass
`"$@"` from the toplevel script in to it, otherwise the options will be blank
when you pass them to `cmdarg_parse`.

Any argument parsed that has a validator assigned, and whose validator returns
nonzero, is considered a failure. Any REQUIRED argument that is not specified is
considered a failure. However, it is worth noting that if a required argument has
a default value, and you provide an empty value to it, we won't know any better
and that will be accepted (how do we know you didn't actually *mean* to do
that?).

For every argument integer, boolean or string argument, an associative array
`cmdarg_cfg` is populated with the long version of the option. E.g., in the
example above, `-c` would become `${cmdarg_cfg[groupmap]}`, for friendlier access
during scripting.

    cmdarg 'x:' 'some required thing'
    cmdarg_parse "$@"
    echo ${cmdarg_cfg['x']}

## Positional Arguments & --

Like any good option parsing framework, cmdarg understands '--' and positional
arguments that are meant to be provided without any kind of option parsing
applied to them. So if you have:

    myscript.sh -x 0 --longopt thingy file1 file2

It would seem reasonable to assume that `-x` and `--longopt` would be parsed as
expected; with arguments of 0 and thingy. But what to do with file1 and file2?
cmdarg puts those into a bash indexed array called cmdarg_argv.

Similarly, cmdarg understands '--' which means "stop processing arguments, the
rest of this stuff is just to be passed to the program directly". So in this
case:

    myscript.sh -x 0 --longopt thingy -- --some-thing-with-dashes

Cmdarg would parse `-x` and `--longopt` as expected, and then `${cmdarg_argv[0]}`
would hold "--some-thing-with-dashes", for your program to do with what it will.

## Automatic Help Messages

cmdarg takes the pain out of creating your `--help` messages. For example,
consider this script:

    #!/bin/bash
    source /usr/lib/blip.bash
    declare -a myarray=()

    cmdarg_info "header" "Some script that needed argument parsing"
    cmdarg_info "author" "Some Poor Bastard <somepoorbastard@hell.com>"
    cmdarg_info "copyright" "(C) 2013"
    cmdarg 'R:' 'required-thing' 'Some thing I REALLY require'
    cmdarg 'r:' 'required-thing-with-default' 'Some thing I require' 'Some default'
    cmdarg 'o?' 'optional-thing' 'Some optional thing'
    cmdarg 'b' 'boolean-thing' 'Some boolean thing'
    cmdarg 'a?[]' 'myarray' 'Some array of stuff'
    cmdarg_parse "$@"

If you ran this script `--help`, you would presented with a nice preformatted
help message:

    $ test.sh --help
    test.sh
    (C) 2013 : Some Poor Bastard <somepoorbastard@hell.com>
    
    Some script that needed argument parsing
    
    Required arguments:
     -R, --required-thing=VALUE : String. Some thing I REALLY require.
    
    Optional arguments:
     -h, --help : Boolean. Show this help.
     -r, --required-thing-with-default=VALUE : String. Some thing I require. (Default "Some default")
     -o, --optional-thing=VALUE : String. Some optional thing.
     -b, --boolean-thing : Boolean. Some boolean thing.
     -a, --myarray=VALUE : Array. Some array of stuff. (See note)
    
    Note: arguments of Array & Hash types may be specified multiple times.

You can change the formatting of help messages with helper functions. (see
Helpers, below).

## Helper Functions

cmdarg is meant to be extensible by default, so there are some places where you
can hook into it to change cmdarg's behavior. By changing the members of the
cmdarg_helpers hash, like this:

    # Change the way arguments are described in --help
    cmdarg_helpers['describe']=my_description_function
    # Completely replace cmdarg's builtin --help message generator with your own
    cmdarg_helpers['usage']=my_usage_function

### Description Helper

The description helper is used when you are happy with the overall structure of
how cmdarg prints your usage message (header, required, optional, footer), but
you want to change the way that individual arguments are described. You can do
this by setting `cmdarg_helpers['describe']` to the name of a bash function which
accepts the following parameters (in order):

- `$1` : long option to be described

- `$2` : short option to be described

- `$3` : argument type being described (will be one of `$CMDARG_TYPE_STRING`,
         `$CMDARG_TYPE_BOOLEAN`, `$CMDARG_TYPE_ARRAY` or `$CMDARG_TYPE_HASH`)

- `$4` : any default value that is set for the option being described

- `$5` : the description for the option being described (as provided to
         `cmdarg` previously)

- `$6` : flags for the option being described (a logically OR'ed bitmask of
         `$CMDARG_FLAG_NOARG`, `$CMDARG_FLAG_REQARG`, or `$CMDARG_FLAG_OPTARG`
         - although this as a bitmask and should be treated as such, in
         practice, this is usually an assignment of one of those 3 values)

- `$7` : the name of any validator (if any) set for the option being described

This is every piece of information cmdarg keeps related to an argument (aside
from its value). You can use these to describe the argument however you please.
Your function must print the text description to stdout. The return value of your
function is ignored.

For examples of this behavior, see `examples/` and `tests/`.

## Usage Helper

The usage helper is used when you want to completely override cmdarg's built in
`--help` handler. Note that, when you override the usage helper, you will no longer
benefit from the description helper, since that is called from inside of the
default usage handler. If you override the usage helper, you will have to
implement 100% of `--help` functionality on your own.

The short options for all specified arguments in cmdarg are kept in a hash
`${CMDARG}` which maps short arguments (`-x`) to long arguments
(`--long-version-of-x`). However, it is not recommended that you iterate over this
hash directly, as the order of hash key iteration is not guaranteed, so your
`--help` message will change every time. To help with this, cmdarg populates two
one-dimensional arrays, `CMDARG_OPTIONAL` and `CMDARG_REQUIRED` with the short
options of all optional and require arguments, respectively. It is recommended
that you iterate over these arrays instead of CMDARG to ensure an ordered
output. It is further recommended that you still utilize cmdarg_describe to
describe each individual argument, since this abstracts away the logic of how to
get the flags, the type, etc of the argument, and lets you continue to provide a
standard interface for your API developer(s).

For examples of this behavior, see `examples/` and `tests/`.

## Errant Behaviour

By default, whenever something happens that `cmdarg` doesn't like, it will
`return 1` up the stack to the caller. You can change this behavior by setting
the `$CMDARG_ERROR_BEHAVIOR` variable to the function or builtin you want called
whenever an error is encountered.

For example, to call a function called `custom_error_function` whenever an error
condition occurs:

    CMDARG_ERROR_BEHAVIOR=custom_error_function

`$CMDARG_ERROR_BEHAVIOR` is treated as a function call (e.g. `return` or `exit`)
with one argument, the value to return. You will be given no more context
regarding the error (and, in fact, you should not expect this to be called
unless a fatal error has been encountered, whether during setup or parsing).
