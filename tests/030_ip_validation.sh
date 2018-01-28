#!/bin/bash

test_030_ip_validation () {
    # IPv4 address validation.
    declare test_input
    while read -r test_input ; do
        assert_raises "is_ipv4_address $test_input" 0
    done < "${BASH_SOURCE[0]%/*}/ipv4_addresses"
    while read -r test_input ; do
        assert_raises "is_ipv4_address $test_input" 1
    done < "${BASH_SOURCE[0]%/*}/non_ipv4_addresses"

    # IPv4 prefix validation.
    while read -r test_input ; do
        assert_raises "is_ipv4_prefix $test_input" 0
    done < <(grep -v -- "-" "${BASH_SOURCE[0]%/*}/ipv4_prefixes")
    while read -r test_input ; do
        assert_raises "is_ipv4_prefix $test_input" 1
    done < <(grep -- "-" "${BASH_SOURCE[0]%/*}/non_ipv4_prefixes")

    # IPv6 address validation.
    while read -r test_input ; do
        assert_raises "is_ipv6_address $test_input" 0
    done < "${BASH_SOURCE[0]%/*}/ipv6_addresses"
    while read -r test_input ; do
        assert_raises "is_ipv6_address $test_input" 1
    done < "${BASH_SOURCE[0]%/*}/non_ipv6_addresses"

    # IPv6 prefix validation.
    while read -r test_input ; do
        assert_raises "is_ipv6_prefix $test_input" 0
    done < <(grep -v -- "-" "${BASH_SOURCE[0]%/*}/ipv6_prefixes")
    while read -r test_input ; do
        assert_raises "is_ipv6_prefix $test_input" 1
    done < <(grep -- "-" "${BASH_SOURCE[0]%/*}/non_ipv6_prefixes")

    assert_end "${BASH_SOURCE[0]##*/}"
}

