#!/usr/bin/env bash

LOC=metacall
PATH=$PATH:$LOC:$LOC/lib
PYTHONHOME=$LOC/runtimes/python
PIP_TARGET=$LOC/runtimes/python/pip
# Python
PATH=$PATH:$LOC/runtimes/python:$LOC/runtimes/python/Scripts
# NodeJS
PATH=$PATH:$LOC/lib/runtimes/nodejs:$LOC/lib/runtimes/nodejs/lib
# DotNet Core
PATH=$PATH:$LOC/lib/runtimes/dotnet:$LOC/lib/runtimes/dotnet/host/fxr/ # TODO: Add version
# Ruby
PATH=$PATH:$LOC/lib/runtimes/ruby/bin:$LOC/lib/runtimes/ruby/bin/ruby_builtin_dll


# Package Managers Paths
pip_path="$LOC/runtimes/python/Pip/bin/pip"
pip3_path="$LOC/runtimes/python/Pip/bin/pip3"
npm_path="$LOC/runtimes/nodejs/npm"
npx_path="$LOC/runtimes/nodejs/npx"
bundle_path="$LOC/runtimes/ruby/bin/bundle"
bundler_path="$LOC/runtimes/ruby/bin/bundler"
erb_path="$LOC/runtimes/ruby/bin/erb"
gem_path="$LOC/runtimes/ruby/bin/gem"
irb_path="$LOC/runtimes/ruby/bin/irb"
racc_path="$LOC/runtimes/ruby/bin/racc"
rake_path="$LOC/runtimes/ruby/bin/rake"
rbs_path="$LOC/runtimes/ruby/bin/rbs"
rdbg_path="$LOC/runtimes/ruby/bin/rdbg"
rdoc_path="$LOC/runtimes/ruby/bin/rdoc"
ri_path="$LOC/runtimes/ruby/bin/ri"
typeprof_path="$LOC/runtimes/ruby/bin/typeprof"


# Check if it is running a package manager and execute it
# TODO
if [[ "$@" =~ "pip" ]]; then
$LOC/runtimes/python/bin/pip $@
elif [[ "$@" =~ "npm" ]]; then
$LOC/lib/runtimes/nodejs/bin/npm $@
else
echo "No package manager detected. Executing MetaCall CLI."
fi


# MetaCall Environment
CORE_ROOT=$LOC/runtimes/dotnet/shared/Microsoft.NETCore.App/ # TODO: Add version
LOADER_LIBRARY="$LOC/lib"
SERIAL_LIBRARY_PATH="$LOC/lib"
DETOUR_LIBRARY_PATH="$LOC/lib"
PORT_LIBRARY_PATH="$LOC/lib"
[[ -n $LOADER_SCRIPT_PATH ]] && LOADER_SCRIPT_PATH="$CWD"
CONFIGURATION_PATH=$LOC/configurations/global.json

# Execute MetaCall CLI 
$LOC/metacallcli.app/Contents/MacOS/metacallcli $@
