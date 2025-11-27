#!/usr/bin/env bash
set -euxo pipefail

# Install latest brew
if [[ $(command -v brew) == "" ]]; then
    echo "Installing brew in order to build MetaCall"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Get brew formula
curl -fsSLO https://raw.githubusercontent.com/metacall/homebrew/main/metacall.rb

# Select the build type
if [ "${1:-}" == "debug" ]; then
    echo "Build Mode: Debug"

    # Replace the build type by debug
    sed -i '' '/-DCMAKE_BUILD_TYPE=/c\
      -DCMAKE_BUILD_TYPE=Debug
' metacall.rb

    # TODO: Add support for preloading address sanitizer in executables using MetaCall
#     sed -i '' '/-DCMAKE_BUILD_TYPE=Debug/a\
#       -DOPTION_BUILD_ADDRESS_SANITIZER=ON
# ' metacall.rb

    # Replace the CLI name
    sed -i '' 's/metacallcli/metacallclid/g' metacall.rb

    # Debug print the recipe
    cat metacall.rb

	# Set debug mode
	METACALL_DEBUG="-dbg"

elif [ "${1:-}" == "release" ] || [ -z "${1:-}" ]; then
    echo "Build Mode: Release"

	# Set debug mode
	METACALL_DEBUG=""
else
    echo "Error: Invalid mode. Please use 'debug' or 'release'."
    exit 1
fi

# Build metacall brew recipe
export HOMEBREW_NO_AUTO_UPDATE=1
brew tap-new metacall/core
mv ./metacall.rb $(brew --repository)/Library/Taps/metacall/homebrew-core/Formula/metacall.rb
brew install --formula metacall/core/metacall --overwrite --verbose

# Build distributable binary using brew pkg
function architecture() {
	local arch=$(uname -m)

	case ${arch} in
		x86_64)
			echo "amd64"
			return
			;;
		arm64)
			echo "arm64"
			return
			;;
	esac

    echo "Invalid architecture: ${arch}"
    exit 1
}

METACALL_VERSION=`brew info metacall | grep -i "stable" | awk '{print $4}' | sed 's/.$//'`
METACALL_ARCH=`architecture`

echo "Packaging MetaCall ${METACALL_VERSION} on ${METACALL_ARCH}"

mkdir release
brew tap --verbose metacall/brew-pkg
brew install --verbose --HEAD metacall/brew-pkg/brew-pkg
brew pkg --name metacall --compress --additional-deps python@3.13,ruby@3.3 metacall
mv metacall.pkg release/metacall-tarball-macos-${METACALL_ARCH}${METACALL_DEBUG}.pkg
mv metacall.tar.gz release/metacall-tarball-macos-${METACALL_ARCH}${METACALL_DEBUG}.tar.gz
