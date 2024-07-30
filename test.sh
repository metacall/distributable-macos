#!/bin/bash

# The format of commands (i.e tests/node/commands.txt) must always contain a new line at the end

loc="$(dirname "$0")/tests"

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

echo "Python tests"
export LOADER_SCRIPT_PATH="$loc/python"

# TODO: We should put this into the launcher
PYTHONHOME="$(dirname "$0")/metacall/runtimes/python"
PIP_TARGET="$PYTHONHOME/Pip"
PATH="$PYTHONHOME:$PYTHONHOME/Scripts:$PATH"
"$PYTHONHOME/python" -m pip install --upgrade --force-reinstall pip

echo "Pip Test"
metacall pip install metacall > out.txt
if [ $? -eq 1 ]; then
    cat out.txt
    echo "Test suite failed"
    rm out.txt
    exit 1
fi
cat out.txt
echo "Successful!!"
echo "Python metacall test"
cat "$loc/python/commands.txt" | metacall > out.txt
if [ $? -eq 1 ]; then
    cat out.txt
    echo "Test suite failed"
    rm out.txt
    exit 1
fi
if ! grep -q "Hello World" out.txt; then
    cat out.txt
    echo "Test suite failed"
    rm out.txt
    exit 1
fi
cat out.txt
echo "Successful!!"

rm out.txt
exit 0
