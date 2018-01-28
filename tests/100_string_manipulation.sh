#!/bin/bash

test_100_string_manipulation () {
    declare -x test_string="  Test string!  "

    assert "trim '$test_string'" "Test string!"

    assert_raises "is_word_in_string '$test_string' 'string'" 0
    assert_raises "is_word_in_string '$test_string' 'Test'" 0
    assert_raises "is_word_in_string '$test_string' 'Test string'" 0
    assert_raises "is_word_in_string '$test_string' 'es'" 1
    assert_raises "is_word_in_string '$test_string' 'Tes'" 1
    assert_raises "is_word_in_string '$test_string' 'est'" 1
    assert_raises "is_word_in_string '$test_string' 'str'" 1
    assert_raises "is_word_in_string '$test_string' 'ing'" 1
    assert_raises "is_word_in_string '$test_string' 'trin'" 1

    assert "to_upper '$test_string'" "  TEST STRING!  "
    assert "to_lower '$test_string'" "  test string!  "

    assert "abs '-273'" "273"
    assert "absolute '-273'" "273"
    assert "abs '-273.15'" "273.15"
    assert "absolute '-273.15'" "273.15"

    assert "abs '273'" "273"
    assert "absolute '273'" "273"
    assert "abs '273.15'" "273.15"
    assert "absolute '273.15'" "273.15"

    assert "abs '+273'" "+273"
    assert "absolute '+273'" "+273"
    assert "abs '+273.15'" "+273.15"
    assert "absolute '+273.15'" "+273.15"

    assert "get_max_length 'cat' 'dog' 'kangaroo' 'mouse'" 8

    assert_end "${BASH_SOURCE[0]##*/}"
}

