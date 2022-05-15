#!/usr/bin/env bash

LOC=metacall
PATH=$PATH:$LOC:$LOC/lib
PYTHONHOME=$LOC/runtimes/python
PIP_TARGET=$LOC/runtimes/python/Pip
# Python
PATH=$PATH:$LOC/runtimes/python:$LOC/runtimes/python/Scripts
# NodeJS
PATH=$PATH:$LOC/lib/runtimes/nodejs:$LOC/lib/runtimes/nodejs/lib
# DotNet Core
PATH=$PATH:$LOC/lib/runtimes/dotnet:$LOC/lib/runtimes/dotnet/host/fxr/ # TODO: Add version

# Check if it is running a package manager and execute it
# WTF

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
