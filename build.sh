#!/usr/bin/env bash

set -exuo pipefail

echo "Checking Compiler and Build System"
command -v cmake &>/dev/null && CMAKE_PRESENT=1 || CMAKE_PRESENT=0
command -v curl &>/dev/null && CURL_PRESENT=1 || CURL_PRESENT=0

error() {
	echo "Error: $1, build stopping, probably dependencies could not be downloaded."
	exit 1
}

echo "CMAKE:$CMAKE_PRESENT,CURL:$CURL_PRESENT"
[[ -n "$CURL_PRESENT" ]] || error "CURL is not present and is absolutely required for now."

MOUNTED_CMAKE_PATH="" # Global for cleanup phase
UPSTREAM_URL="https://github.com/metacall/core.git" 

# TODO: Download and add to PATH, dotnet binaries
LOC="$PWD/metacall"
CWD="$PWD"
(mkdir -p "$LOC" && cd "$LOC") || error "cd $LOC failed"
PYTHON_LOC="$LOC/runtimes/python"
RUBY_LOC="$LOC/runtimes/ruby"
NODEJS_LOC="$LOC/runtimes/nodejs"
DOTNET_LOC="$LOC/runtimes/dotnet"

download() {
	curl -sL "$1" -o "$2" || return 1
}

get_latest_release() {
	# Get latest release from GitHub API, get tag line and pluck JSON value
	curl --silent "https://api.github.com/repos/$1/releases/latest" | \
	grep '"tag_name":' | \
	sed -E 's/.*"([^"]+)".*/\1/'
}

download_from_github() {
	repo="$1"
	tag="$2"
	file="$3"

	download "https://github.com/$repo/releases/download/$tag/$file" "$file" || error "Cmake download failed"
}

download_cmake() {
	repo="kitware/cmake"
	version="$(get_latest_release $repo)"
	download_from_github "$repo" "$version" "cmake-${version#"v"}-macos-universal.dmg" || return 1
	MOUNTED_CMAKE_PATH="$(yes | hdiutil attach cmake-${version#"v"}-macos-universal.dmg | tail -n 1 | cut -d$'\t' -f 3)"
	export PATH="$MOUNTED_CMAKE_PATH/CMake.app/Contents/bin":"$PATH"
	hdiutil detach "$MOUNTED_CMAKE_PATH"
	# TODO: CLEANUP see cleanup functions
}


download_dotnet(){
	echo "Downloading Dotnet" && return 0
	download "" dotnet || return 1
}

download_ruby(){
	echo "Downloading Ruby" && return 0
	download "" ruby || return 1
}

download_dependencies() {
	echo "Downloading dependencies"
	# DOWNLOAD just about everything, we need for portability.
	mkdir -p "$LOC/dependencies"
	cd "$LOC/dependencies" || error "cd $LOC/dependencies failed"
	download_install_python3 || error "Python3 download failed" 
	#download_dotnet || error "Dotnet-sdk download failed"
	#download_ruby   || error "Ruby download failed"
	# TODO: Download Dotnet sdk/runtime binaries add to path
	# TODO: Download Ruby either RubyMotion or RubyApp 
	# https://github.com/gosu/ruby-app
}

extract_deps() {
	declare runtime_folder="$1"
	mkdir -p "$runtime_folder"
	echo "Extracting archives"
	#mkdir -p "$LOC/runtimes/ruby"
	mkdir -p "$LOC/runtimes/python"
	#mkdir -p "$LOC/runtimes/dotnet"
	mkdir -p "$LOC/runtimes/nodejs"
	#extract_python3 $runtime_folder
	#extract_dotnet $runtime_folder/dotnet
	#extract_ruby $runtime_folder
}

install_deps() {
	echo "Install dependency"
}


download_install_python3(){
	mkdir -p "$PYTHON_LOC"
	echo "Downloading Python3"
	cd "$PYTHON_LOC"
	git clone "https://github.com/gregneagle/relocatable-python" || echo "Make sure that you cloned gregneabgle/relocatable-python"
	echo "Making Python3 relocatable in $PYTHON_LOC"
	python3 "$PYTHON_LOC"/relocatable-python/make_relocatable_python_framework.py --destination "$PYTHON_LOC" --python-version 3.7.4 || error "Python 3 relocatable make failed."
}

download_install_ruby() {
	echo "Downloading ruby"
}

patch_cmake_python() {
	echo "set(Python_VERSION 3.7.4)"> "$LOC/core/cmake/FindPython.cmake"
	echo "set(Python_ROOT_DIR "$LOC/runtimes/python/Python.framework")">> "$LOC/core/cmake/FindPython.cmake"
	echo "set(Python_EXECUTABLE \"$LOC/runtimes/python/Python.framework/Resources/Python.app/Contents/MacOS/Python\")">> "$LOC/core/cmake/FindPython.cmake"
	echo "set(Python_INCLUDE_DIRS \"$LOC/runtimes/python/Python.framework/Versions/Current/include/python3.7m\")">> "$LOC/core/cmake/FindPython.cmake"
	echo "set(Python_LIBRARIES \"$LOC/runtimes/python/Python.framework/Versions/Current/lib/libpython3.7.dylib\")">> "$LOC/core/cmake/FindPython.cmake"
	echo "include(FindPackageHandleStandardArgs)">> "$LOC/core/cmake/FindPython.cmake"
	echo "FIND_PACKAGE_HANDLE_STANDARD_ARGS(Python REQUIRED_VARS Python_EXECUTABLE Python_LIBRARIES Python_INCLUDE_DIRS VERSION_VAR Python_VERSION)">> "$LOC/core/cmake/FindPython.cmake"
	echo "mark_as_advanced(Python_EXECUTABLE Python_LIBRARIES Python_INCLUDE_DIRS)">> "$LOC/core/cmake/FindPython.cmake"
}

patch_cmake_ruby() {
	echo "set(Ruby_VERSION 2.4.10)" > "$LOC/core/cmake/FindRuby.cmake"
	echo "set(Ruby_ROOT_DIR $LOC/runtimes/ruby)" >> "$LOC/core/cmake/FindRuby.cmake"
	echo "set(Ruby_EXECUTABLE $LOC/runtimes/ruby/bin/ruby)" >> "$LOC/core/cmake/FindRuby.cmake"
	echo "set(Ruby_INCLUDE_DIRS $LOC/runtimes/ruby/include/;$LOC/runtimes/ruby/include/ruby/)" >> "$LOC/core/cmake/FindRuby.cmake"
	echo "set(Ruby_LIBRARY "$LOC/runtimes/ruby/lib/x64-vcruntime140-ruby310.lib")" >> "$LOC/core/cmake/FindRuby.cmake"
	echo "include(FindPackageHandleStandardArgs)" >> "$LOC/core/cmake/FindRuby.cmake"
	echo "FIND_PACKAGE_HANDLE_STANDARD_ARGS(Ruby REQUIRED_VARS Ruby_EXECUTABLE Ruby_LIBRARY Ruby_INCLUDE_DIRS VERSION_VAR Ruby_VERSION)" >> "$LOC/core/cmake/FindRuby.cmake"
	echo "mark_as_advanced(Ruby_EXECUTABLE Ruby_LIBRARY Ruby_INCLUDE_DIRS)" >> "$LOC/core/cmake/FindRuby.cmake"
}

build_meta() {
	cd "$LOC" || error "cd $LOC failed"
	echo "Building MetaCall" 

	# Install Python certificates
	bash /Applications/Python\ 3*/Install\ Certificates.command
	bash /Applications/Python\ 3*/Update\ Shell\ Profile.command

	# Install XCode dependencies
	sudo xcode-select --install
	sudo xcode-select --switch /Library/Developer/CommandLineTools

	# Export compiler options
	export SDKROOT=$(xcrun --show-sdk-path)
	export MACOSX_DEPLOYMENT_TARGET=''
	export CC=$(xcrun --find clang)
	export CXX=$(xcrun --find clang++)

	# Clone repo
	if [ ! -d "$LOC/core" ] ; then # if repo does not exist
		git clone --depth 1 "$UPSTREAM_URL" || error "Git clone metacall/core failed"
	else
		cd "$LOC/core"
		git pull "$UPSTREAM_URL" || error "Git pull failed" # if it does we just pull
	fi

	# Create build folder
	mkdir -p "$LOC/core/build"
	cd "$LOC/core/build" || error "cd $LOC/core/build failed" 

	# Configure
	cmake -Wno-dev \
		-DCMAKE_BUILD_TYPE=Release \
		-DOPTION_BUILD_SECURITY=OFF \
		-DOPTION_FORK_SAFE=OFF \
		-DOPTION_BUILD_SCRIPTS=OFF \
		-DOPTION_BUILD_TESTS=OFF \
		-DOPTION_BUILD_EXAMPLES=OFF \
		-DOPTION_BUILD_LOADERS_PY=ON \
		-DOPTION_BUILD_LOADERS_NODE=OFF \
		-DOPTION_BUILD_LOADERS_CS=OFF \
		-DOPTION_BUILD_LOADERS_RB=OFF \
		-DOPTION_BUILD_LOADERS_TS=OFF \
		-DOPTION_BUILD_PORTS=ON \
		-DOPTION_BUILD_PORTS_PY=ON \
		-DOPTION_BUILD_PORTS_NODE=OFF \
		-DCMAKE_INSTALL_PREFIX="$LOC" \
		-G "Unix Makefiles" .. || error "Cmake configuration failed."

	# Build
	cmake --build . --target install || error "Cmake build target install failed."
}

make_metacallcli() {
	echo Metacall.sh make CLI scripts with paths
	# TODO: Setup paths to runtime and put them all in sh script
	echo "Finished Building MetaCall"
}

cleanup() { # TODO: Put right when we don't need anymore lots of files						# the cleanup
	echo Cleaning up && return 0
	hdiutil detach "$MOUNTED_CMAKE_PATH" || error #cleanup CMAKE 
	# TODO: Delete file downloaded from upstream
}


make_tarball() {
	cd "$CWD" || error "cd $CWD failed"
	echo "Compressing tarball"
	cmake -E tar "cf" "$CWD/metacall-tarball-macos-x64.zip" --format=zip "$LOC" "$CWD/metacall.sh"
	echo "tarball compressed successfully."
	return 0
}

post_build() {
	echo "Deleting unecessary temp folders."
	rm -rf "$LOC/core"
	rm -rf "$LOC/dependencies"
	rm -rf "$LOC/runtimes"
	# TODO: Delete runtimes/dotnet/include & runtimes/python/ if present
	# TODO: move library dependencies to the correct folders for 
	# libnode & ruby if needed
}

# If cmake not present, we'll download it and use that one
[[ -n $CMAKE_PRESENT ]] || download_cmake && download_dependencies && extract_deps "$LOC/dependencies/runtime" && install_deps && build_meta && make_metacallcli && post_build && make_tarball && exit 0

# If cmake is present then use it
download_dependencies && extract_deps "$LOC/dependencies/runtime" && install_deps && build_meta && make_metacallcli && post_build && make_tarball && cleanup && exit 0

