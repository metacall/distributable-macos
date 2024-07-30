#!/usr/bin/env bash
set -euxo pipefail

# Install latest brew
if [[ $(command -v brew) == "" ]]; then
    echo "Installing brew in order to build MetaCall"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Get brew formula
wget https://raw.githubusercontent.com/metacall/homebrew/main/metacall.rb

export HOMEBREW_NO_AUTO_UPDATE=1

# Build metacall brew recipe
brew install ./metacall.rb --build-from-source --overwrite -v

# Build distributable binary using brew pkg
architecture() {
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

METACALL_VERSION=`brew info metacall | grep -i "stable" | awk '{print $4}'`
METACALL_ARCH=`architecture`

mkdir pkg && cd pkg
brew tap timsutton/formulae
brew install brew-pkg
brew pkg --with-deps metacall
mv metacall-${METACALL_VERSION}.pkg metacall-tarball-macos-${METACALL_ARCH}.pkg
