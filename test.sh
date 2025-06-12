#!/bin/sh

# Debug
# export DYLD_PRINT_LIBRARIES=1
# export DYLD_PRINT_LIBRARIES_POST_LAUNCH=1
# export DYLD_PRINT_RPATHS=1

repl_test() {
    echo "$1"
    TEST_COMMAND="`echo $2 | metacall`"
    if echo "$TEST_COMMAND" | grep -q "$3"; then
        echo "$TEST_COMMAND"
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

cli_test() {
    echo "$1"
    TEST_COMMAND="`$2 $3`"
    if echo "$TEST_COMMAND" | grep -q "$4"; then
        echo "$TEST_COMMAND"
        echo "Passed"
    else
        echo "Failed"
        echo "Commands:"
        echo "$2 $3"
        echo "Expected: $4"
        echo "Received: $TEST_COMMAND"
        exit 1
    fi
}

echo "Python Tests"

repl_test \
    "Running Python Reverse Words Test" \
    'load py tests/python/repl.py\ninspect\ncall reverse_words("hello world")\nexit' \
    "dlrow olleh"

repl_test \
    "Running Python Factorial Test" \
    "load py tests/python/repl.py\ninspect\ncall factorial(3)\nexit" \
    "6"

cli_test \
    "Running Python MetaCall Port Test" \
    "metacall" "tests/python/port.py" \
    "Python Port"

# Define Python path so it can find MetaCall package
export PYTHONPATH="$(brew --prefix)/lib/python"

cli_test \
    "Running Python Executable Port Test" \
    "python3" "tests/python/port.py" \
    "Python Port"

echo "NodeJS Tests"

repl_test \
    "Running NodeJS Reverse Words Test" \
    'load node tests/node/repl.js\ninspect\ncall reverseWord("hello world")\nexit' \
    "dlrow olleh"

repl_test \
    "Running NodeJS Factorial Test" \
    "load node tests/node/repl.js\ninspect\ncall factorial(3)\nexit" \
    "6"

cli_test \
    "Running NodeJS MetaCall Port Test" \
    "metacall" "tests/node/port.js" \
    "NodeJS Port"

# Define NodeJS path so it can find MetaCall package
export NODE_PATH="$(brew --prefix)/lib/node_modules"

cli_test \
    "Running NodeJS Executable Port Test" \
    "node" "tests/node/port.js" \
    "NodeJS Port"
