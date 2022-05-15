#!/usr/bin/env bash
set -o nounset # raise error if a var is not defined
echo "Checking Compiler and Build System"
command -v cmake &>/dev/null && CMAKE_PRESENT=1
MOUNTED_CMAKE_PATH="" # Global for cleanup phase
UPSTREAM_URL="https://github.com/metacall/core.git" 
# TODO: Download and add to PATH, dotnet binaries

error() {
  echo "Error: $1, build stopping, probably dependencies could not be downloaded."
  exit 1
}

LOC="$PWD/metacall"
CWD="$PWD"
(mkdir -p "$LOC" && cd "$LOC") || error "cd $LOC failed"

download() {
  curl -sL "$1 -o $2" || return 1
}

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
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
  echo "Unknown command quitting on purpose" && return 0
  MOUNTED_CMAKE_PATH="$(yes | hdiutil attach cmake-${version#"v"}-macos-universal.dmg | tail -n 1 | cut -d$'\t' -f 3)"
  export PATH="$MOUNTED_CMAKE_PATH/CMake.app/Contents/bin":"$PATH"
  # TODO: CLEANUP see cleanup functions
}

check_python3() {
  for filename in /Applications/*;do
    if [[ "$filename" =~ "Python".* ]];then # regexp for Python 3.XX
      return 1 # Python is installed
     else 
      return 0 # Consider no Python installed (ignoring the xcode one for now)
    fi
  done
}

download_install_python3(){
  echo "Downloading Python3"
  download "https://www.python.org/ftp/python/3.10.4/python-3.10.4-macos11.pkg" python3.pkg || return 1
  echo "Installing Python3 with Universal pkg file (require sudo)"
  mkdir -p $LOC/runtimes/python
  sudo installer -pkg python3.pkg -target $LOC/runtimes/python || error "Python installation failed"
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
  check_python3
  PYTHON_PRESENT=$?
  echo "Value of Python Present is: $PYTHON_PRESENT"
  if [[ PYTHON_PRESENT -eq 0 ]];then
	  download_install_python3 || error "Python3 download failed." 
  fi
  download_dotnet  || error "Dotnet-sdk download failed"
  download_ruby    || error "Ruby download failed"
  # TODO: Download Dotnet sdk/runtime binaries add to path
  # TODO: Download Ruby either RubyMotion or RubyApp 
  # https://github.com/gosu/ruby-app
}

extract_deps() {
  declare runtime_folder="$1"
  mkdir -p "$runtime_folder"
  echo "Extracting archives"
  mkdir -p "$LOC/runtimes/ruby"
  #mkdir -p "$LOC/runtimes/python"
  mkdir -p "$LOC/runtimes/dotnet"
  mkdir -p "$LOC/runtimes/nodejs"
  #extract_python3 $runtime_folder
  #extract_dotnet $runtime_folder/dotnet
  #extract_ruby $runtime_folder
}

install_deps() {
  echo "Install dependency"
}

build_meta() {
  cd "$LOC" || error "cd $LOC failed"
  echo "Building MetaCall" 
  if [ ! -d "$LOC/core" ] ; then # if repo does not exist
    git clone --depth 1 "$UPSTREAM_URL" || error "Git clone metacall/core failed"
  else
    cd "$LOC/core"
    git pull "$UPSTREAM_URL" || error "Git pull failed" # if it does we just pull
  fi
  mkdir -p "$LOC/core/build"
  cd "$LOC/core/build" || error "cd $LOC/core/build failed" 
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
  cmake --build . --target install || error "Cmake build target install failed."
}

make_metacallcli() {
  echo Metacall.sh make CLI scripts with paths
  # TODO: Setup paths to runtime and put them all in sh script
  echo "Finished Building MetaCall"
}

cleanup() { # TODO: Put right when we don't need anymore lots of files
            # the cleanup
  echo Cleaning up && return 0
  hdiutil detach "$MOUNTED_CMAKE_PATH" || error #cleanup CMAKE 
  # TODO: Delete file donwloaded from upstream
}


make_tarball() {
	cd "$CWD" || error "cd $CWD failed"
	echo "Compressing Tarball"
	cmake -E tar "cf" "$CWD/metacall-tarball-macos-x64.zip" --format=zip "$LOC" "$CWD/metacall.sh"
	echo "Tarball compressed successfully."
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
[[ -n $CMAKE_PRESENT  ]] || download_cmake && download_dependencies && extract_deps "$LOC/dependencies/runtime" && install_deps && build_meta && make_metacallcli && post_build && make_tarball && exit 0

# If cmake is present then use it
download_dependencies && extract_deps "$LOC/dependencies/runtime" && install_deps && build_meta && make_metacallcli && post_build && make_tarball && cleanup && exit 0
