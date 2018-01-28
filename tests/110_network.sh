#!/bin/bash

test_110_network () {
    declare url="http://www.google.com"
    declare skip=0
    curl -ks --connect-timeout 5 "$url" >/dev/null 2>&1 || skip=$?

    [[ $skip -ne 0 ]] && skip
    assert_raises "url_exists '$url'" 0
    [[ $skip -ne 0 ]] && skip
    assert "url_http_response '$url'" "200 OK"
    [[ $skip -ne 0 ]] && skip
    assert "url_http_response_code '$url'" "200"

    assert_end "${BASH_SOURCE[0]##*/}"
}

