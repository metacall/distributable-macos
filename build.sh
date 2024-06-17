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

# # Fix libuv manually as homebrew does not allow force linking via the formula
# brew install libuv
# brew link --overwrite libuv

# Build metacall brew recipe
brew install ./metacall.rb --build-from-source --overwrite -v

# Build distributable binary using brew pkg
mkdir pkg && cd pkg
brew tap timsutton/formulae
brew install brew-pkg
brew pkg --with-deps --without-kegs metacall
