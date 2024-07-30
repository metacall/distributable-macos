#!/bin/bash

metacall

if [ $? -ne 0 ]; then
    echo "Error: Command failed with non-zero exit code" >&2
    exit 1
fi

cd tests/node && metacall test.js


if [ $? -ne 0 ]; then
    echo "Error: Command failed with non-zero exit code" >&2
    exit 1
fi

cd ./../python && metacall test.py
if [ $? -ne 0 ]; then
    echo "Error: Command failed with non-zero exit code" >&2
    exit 1
fi