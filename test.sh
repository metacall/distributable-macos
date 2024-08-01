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
