#!/usr/bin/env bash
set -euxo pipefail

# Install latest brew
if [[ $(command -v brew) == "" ]]; then
    echo "Installing brew in order to build MetaCall"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Get brew formula
curl -fsSLO https://raw.githubusercontent.com/metacall/homebrew/main/metacall.rb

# Build metacall brew recipe
export HOMEBREW_NO_AUTO_UPDATE=1
brew install --build-from-source --overwrite --verbose ./metacall.rb

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

mkdir release
brew tap --verbose metacall/brew-pkg
brew install --verbose --HEAD metacall/brew-pkg/brew-pkg
brew pkg --with-deps --compress metacall
mv metacall-${METACALL_VERSION}.pkg release/metacall-tarball-macos-${METACALL_ARCH}.pkg
mv metacall-${METACALL_VERSION}.tgz release/metacall-tarball-macos-${METACALL_ARCH}.tgz
