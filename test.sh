#!/bin/sh

repl_test() {
    echo "$1"
    TEST_COMMAND="`echo $2 | metacall`"
    if echo "$TEST_COMMAND" | grep -q "$3"; then
        echo "Passed"
    else
        echo "Failed"
        echo "Commands:"
        echo "$2"
        echo "Expected: $3"
        echo "Received: $TEST_COMMAND"
        exit 1
    fi
}

echo "Python Tests"

<<<<<<< HEAD
repl_test \
    "Running Python Reverse Words Test" \
    'load py tests/python/test.py\ninspect\ncall reverse_words("hello world")\nexit' \
    "dlrow olleh"
=======
# echo "NodeJS tests"
# export LOADER_SCRIPT_PATH="$loc/node"
# echo "Npm Test"
# metacall npm install metacall > out.txt
# if [ $? -eq 1 ]; then
#     cat out.txt
#     echo "Test suite failed"
#     rm out.txt
#     exit 1
# fi
# cat out.txt
# echo "Successful!!"
# echo "Node metacall test"
# cat "$loc/node/commands.txt" | metacall > out.txt
# if [ $? -eq 1 ]; then
#     cat out.txt
#     echo "Test suite failed"
#     rm out.txt
#     exit 1
# fi
# if ! grep -q "366667" out.txt; then
#     cat out.txt
#     echo "Test suite failed"
#     rm out.txt
#     exit 1
# fi
# cat out.txt
# echo "Successful!!"
>>>>>>> 8848337 (comment nodejs tests)

repl_test \
    "Running Python Factorial Test" \
    "load py tests/python/test.py\ninspect\ncall factorial(3)\nexit" \
    "6"

echo "NodeJS Tests"

repl_test \
    "Running NodeJS Reverse Words Test" \
    'load node tests/node/test.js\ninspect\ncall reverseWord("hello world")\nexit' \
    "dlrow olleh"

repl_test \
    "Running NodeJS Factorial Test" \
    "load node tests/node/test.js\ninspect\ncall factorial(3)\nexit" \
    "6"

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