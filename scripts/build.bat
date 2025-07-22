@echo off
setlocal enabledelayedexpansion

rem Get the folder this script is in
set SCRIPT_DIR=%~dp0

rem Read version from file in script directory
set /p VERSION=<"%SCRIPT_DIR%version.txt"

rem Ensure bin directory exists
if not exist "bin" (
    mkdir "bin"
)

rem Run the build
echo Building Rune version %VERSION%
odin build "src" -out:"bin/rune.exe" -collection:rune=src/ -define:VERSION=%VERSION%
