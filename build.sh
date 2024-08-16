#!/usr/bin/env bash
set -euxo pipefail

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# Install latest brew
if [[ $(command -v brew) == "" ]]; then
    echo "Installing brew in order to build MetaCall"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Get brew formula
brew install wget
wget https://raw.githubusercontent.com/metacall/homebrew/main/metacall.rb

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

# Extract the .tgz file
tar -xzvf metacall-${METACALL_VERSION}.tgz
mkdir distributable
cp -r private/tmp/brew-pkg[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]*-[a-z0-9]*/opt/homebrew/Cellar/metacall/[0-9]*.[0-9]*.[0-9]* distributable/metacall-core
cp private/tmp/brew-pkg[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]*-[a-z0-9]*/opt/homebrew/bin/metacall distributable/
sed -i '' '2s|^PREFIX=.*|PREFIX=metacall-core|' "distributable/metacall"
tar -czf metacall-tarball-macos-${METACALL_ARCH}.tgz distributable
mv metacall-tarball-macos-${METACALL_ARCH}.tgz release/
