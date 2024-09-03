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

# Extract the .tgz file
tar -xzvf metacall-${METACALL_VERSION}.tgz
mkdir distributable

INSTALL_DIR=""
# Specify install directory
if [ "$METACALL_ARCH" = "arm64" ]; then
    INSTALL_DIR="opt/homebrew"
else
    INSTALL_DIR="usr/local"
fi

# Copy MetaCall core
cp -R Cellar/metacall/[0-9]*.[0-9]*.[0-9]* distributable/metacall-core
# Copy Ruby
cp -R Cellar/ruby/[0-9]*.[0-9]* distributable/ruby
# Copy Python
cp -R Cellar/python@[0-9]*.[0-9]* distributable/python
# Copy MetaCall binary
cp bin/metacall distributable/

# Change path of shared libraries
change_library_path() {
  loader=$1
  lib_regex=$INSTALL_DIR
  metacall_lib=distributable/metacall-core/lib/lib${loader}_loader.so

  old_lib=$(otool -L "$metacall_lib" | grep -E "$lib_regex" | awk '{print $1}')
  old_lib_regex=$(echo $old_lib | awk -F'/' '{print $(NF-2)"/"$(NF-1)"/"$NF}') # Get the path suffix
  new_lib=$(cd distributable && find . -type f -regex ".*/$old_lib_regex")

  if [ -n "$old_lib" ] && [ -n "$new_lib" ]; then
    install_name_tool -change "$old_lib" "@loader_path/../.$new_lib" "$metacall_lib"
    echo "Updated $loader loader: $old_lib -> $new_lib"
  else
    echo "Failed to update $loader loader: Could not find the old or new library path."
  fi
}

# Update Python loader
change_library_path "py"

# Update Ruby loader
change_library_path "rb"

tar -czf metacall-tarball-macos-${METACALL_ARCH}.tgz distributable
mv metacall-tarball-macos-${METACALL_ARCH}.tgz release/
