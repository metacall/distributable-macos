# MetaCall Distributable MacOS

This repository contains shell scripts to generate MetaCall binaries for MacOS. The project automates the process of installing MetaCall as a Homebrew formula and creating a distributable package using the `brew-pkg` tool.

## Prerequisites

- MacOS operating system
- [Homebrew](https://brew.sh/) package manager
- [brew-pkg](https://github.com/metacall/brew-pkg) tool

## Contents

- `build.sh`: Main script that orchestrates the binary generation process
- `test.sh`: Runs various tests against MetaCall
- `./tests`: Includes language specific tests

## Implementation

This brew formulae compiles MetaCall core for ARM64 and AMD64. The installation process has been optimized to install the dependencies in a dynamic way.

- Enhanced Python setup process
    - Support for detecting Python version and location dynamically.
    - Improved handling of Python paths for both macOS and Linux systems.

- Refined NodeJS installation
    - Installs node executable and other shared libraries separately instead of a brew dependency
    - Bash completion for NPM

- Enhanced Metacall launcher:
    - Added more robust path detection for metacallcli based on the dsitributable type

The final distributable is generated using a Homebrew extension [`brew-pkg`](https://github.com/metacall/brew-pkg). It generates a installable `.pkg` and a portable `.tgz` file. The fork includes some extra features which have been described below.

1. **Recursive library patching**: The function recursively processes linked libraries.

2. **Dynamic linking**: Uses `@executable_path` to create relative paths for dynamic linking.

3. **ELF file validation**: Checks if the target binary is a valid ELF (Executable and Linkable Format) file.

4. **Library dependency analysis**: Uses `otool -L` to identify linked libraries for the given binary.

5. **Path filtering**: Filters library paths to only process those within the specified prefix path.

6. **Relative path calculation**: Computes relative paths between the binary and its linked libraries.

7. **Library path updating**: Uses `install_name_tool` to update library paths in the binary.

## Usage

MetaCall supports `ARM64` and `AMD64` architectures at the moment.
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
