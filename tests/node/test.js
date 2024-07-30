#!/usr/bin/env node

/*
 *	MetaCall Distributable by Parra Studios
 *	Distributable infrastructure for MetaCall.
 *
 *	Copyright (C) 2016 - 2020 Vicente Eduardo Ferrer Garcia <vic798@gmail.com>
 *
 *	Licensed under the Apache License, Version 2.0 (the "License");
 *	you may not use this file except in compliance with the License.
 *	You may obtain a copy of the License at
 *
 *		http://www.apache.org/licenses/LICENSE-2.0
 *
 *	Unless required by applicable law or agreed to in writing, software
 *	distributed under the License is distributed on an "AS IS" BASIS,
 *	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *	See the License for the specific language governing permissions and
 *	limitations under the License.
 *
 */

const { metacall_load_from_file, metacall } = require('metacall');

// Load the Python file
const result = metacall_load_from_file('py', ['example.py']);

if (result) {
    console.log('Python file loaded successfully.');

    // Test the add function from Python
    const sum = metacall('add', 3, 4);
    console.log(`Sum: ${sum}`); // Should print: Sum: 7

    // Test the greet function from Python
    const greeting = metacall('greet', 'World');
    console.log(greeting); // Should print: Hello, World!

    // Add more tests as needed
} else {
    console.error('Failed to load Python file.');
}
