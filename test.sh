#!/bin/sh

echo "Python Tests"

echo "Running Python Reverse Words Test"
echo 'load py tests/python/test.py\ninspect\ncall reverse_words("hello world")\nexit' | metacall | grep "dlrow olleh" || exit 1

echo "Running Python Factorial Test"
echo "load py tests/python/test.py\ninspect\ncall factorial(3)\nexit" | metacall | grep "6" || exit 1

echo "NodeJS Tests"

echo "Running NodeJS Reverse Words Test"
echo 'load node tests/node/test.js\ninspect\ncall reverseWord("hello world")\nexit' | metacall | grep "dlrow olleh" || exit 1

echo "Running NodeJS Factorial Test"
echo "load node tests/node/test.js\ninspect\ncall factorial(3)\nexit" | metacall | grep "6" || exit 1
