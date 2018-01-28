#!/bin/bash

test_070_license () {
    declare -x base="${BASH_SOURCE[0]%/*}/../"
    declare -ax strings=(
            "MIT License"
            "Copyright (c) 2016, 2017 Nicola Worthington"
            )
    for file in blip.bash LICENSE debian/copyright Makefile
    do
        for string in "${strings[@]}"
        do
            assert_raises "grep -w '$string' '${base%/}/$file'" 0
        done
    done

    # Contributors.
    declare -ax strings=(
            "Sergej Alikov <sergej.alikov@gmail.com>"
            "Andrew Kesterson <andrew@aklabs.net>"
            )
    for file in blip.bash LICENSE debian/copyright CONTRIBUTORS
    do
        for string in "${strings[@]}"
        do
            assert_raises "grep -w '$string' '${base%/}/$file'" 0
        done
    done

    assert_end "${BASH_SOURCE[0]##*/}"
}

