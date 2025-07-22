#!/bin/bash

# Get the directory this script is in
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo $SCRIPT_DIR

# Read version from file
VERSION=$(<"$SCRIPT_DIR/version.txt")

# Ensure bin directory exists
mkdir -p "bin"

# Run the build
echo "Building Rune version $VERSION"
odin build "src" -out:"bin/rune" -collection:rune=src/ -define:VERSION="$VERSION"
