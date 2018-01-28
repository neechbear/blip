#!/bin/bash

test_040_hwaddr_validation () {
    # MAC-48 address validation.
    declare test_input
    while read -r test_input ; do
        assert_raises "is_mac_address $test_input" 0
    done < "${BASH_SOURCE[0]%/*}/eui48_addresses"
    while read -r test_input ; do
        assert_raises "is_mac_address $test_input" 1
    done < "${BASH_SOURCE[0]%/*}/non_eui48_addresses"

    # EUI-48 address validation.
    while read -r test_input ; do
        assert_raises "is_eui48_address $test_input" 0
    done < "${BASH_SOURCE[0]%/*}/eui48_addresses"
    while read -r test_input ; do
        assert_raises "is_eui48_address $test_input" 1
    done < "${BASH_SOURCE[0]%/*}/non_eui48_addresses"

    # EUI-64 address validation.
    while read -r test_input ; do
        assert_raises "is_eui64_address $test_input" 0
    done < "${BASH_SOURCE[0]%/*}/eui64_addresses"
    while read -r test_input ; do
        assert_raises "is_eui64_address $test_input" 1
    done < "${BASH_SOURCE[0]%/*}/non_eui64_addresses"

    assert_end "${BASH_SOURCE[0]##*/}"
}

