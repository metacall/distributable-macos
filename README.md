# MetaCall Distributable MacOS

This repository contains shell scripts to generate MetaCall binaries for MacOS. The project automates the process of installing MetaCall as a Homebrew formula and creating a distributable package using the brew-pkg tool.

## Prerequisites

- MacOS operating system
- [Homebrew](https://brew.sh/) package manager
- [brew-pkg](https://github.com/timsutton/brew-pkg) tool

## Contents

- `build.sh`: Main script that orchestrates the binary generation process
- `test.sh`: Runs various tests against MetaCall
- `./tests`: Includes language specific tests

## Usage

Clone the repository and build MetaCall using `./build.sh`.
The script will perform the following actions:
- Install MetaCall as a Homebrew formula
- Generate a distributable package using brew-pkg

Generated files can be found in the `release` directory.

## Customization

To enable/disable any loaders, modify the [formulae](https://github.com/metacall/homebrew/blob/main/metacall.rb) and change the args passed to cmake.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

Please read the license [here](https://github.com/metacall/distributable-macos/blob/master/LICENSE).
