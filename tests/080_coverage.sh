#!/bin/bash

# TODO(nicolaw): Actually write unit tests for all these things!

# assert as_json_string
# assert as_json_value
# assert get_variable_type
# assert vars_as_json
# assert is_newer_version
# assert required_command_version
# assert append_if_not_present
# assert append_trap
# assert execute_trap_stack
# assert get_date
# assert get_exclusive_execution_lock
# assert get_free_disk_space
# assert get_fs_mounts
# assert get_gecos_info
# assert get_gecos_name
# assert get_user_shell
# assert get_pid_lock_filename
# assert get_string_characters
# assert get_trap_stack
# assert get_unixtime
# assert get_user_confirmation
# assert get_username
# assert get_user_selection
# assert pop_trap_stack
# assert push_trap_stack
# assert read_config_file
# assert set_trap_stack
# assert unset_trap_stack
# assert url_http_header
# assert cmdarg
# assert cmdarg_check_empty
# assert cmdarg_describe
# assert cmdarg_describe_default
# assert cmdarg_info
# assert cmdarg_parse
# assert cmdarg_purge
# assert cmdarg_set_opt
# assert cmdarg_usage
# assert cmdarg_validate

test_080_coverage () {
    declare -x blip="${BASH_SOURCE[0]%/*}/../blip.bash"
    declare -x tests="${BASH_SOURCE[0]%/*}"

    # Check all functions feature at least once on the same line as an
    # assert call or some kind. This is very crude, but it is better
    # than nothing given that CodeClimate nor Travis CI provides
    # native test coverage reporting for shell scripts.
    while read -r function ; do
        function="${function%% *}"
        #assert_raises "egrep -w '(assert|assert_raises) .*$function' '$tests'/*.sh" 0
        assert_raises "egrep -w '(assert|assert_raises) .*$function' $tests/*.sh" 0
    done < <(egrep -o '^[a-z_]+\ \(\)' "$blip" | sort -u)

    assert_end "${BASH_SOURCE[0]##*/}"
}

