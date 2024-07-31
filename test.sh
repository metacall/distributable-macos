#!/bin/bash

# Python tests
py_reverse_words=$(echo 'load py tests/python/test.py\ncall reverse_words("hello world")\nexit' | metacall | grep 'dlrow olleh')
if [ -z "$py_reverse_words" ]; then
    exit 1
fi

py_factorial=$(echo 'load py tests/python/test.py\ncall factorial(3)\nexit' | metacall | grep '6')
if [ -z "$py_factorial" ]; then
    exit 1
fi

# NodeJS tests
js_reverse_words=$(echo 'load node tests/node/test.js\ncall reverseWord("hello world")\nexit' | metacall | grep 'dlrow olleh')
if [ -z "$js_reverse_words" ]; then
    exit 1
fi

js_factorial=$(echo 'load node tests/node/test.js\ncall factorial(3)\nexit' | metacall | grep '6')
if [ -z "$js_factorial" ]; then
    exit 1
fi