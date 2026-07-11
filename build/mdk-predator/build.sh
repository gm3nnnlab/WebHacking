#!/bin/bash
#
# MDK-Predator Build Script
# Complete build from clean clone
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check dependencies
print_step "Checking dependencies..."

command -v arm-none-eabi-gcc >/dev/null || {
    print_error "arm-none-eabi-gcc not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y gcc-arm-none-eabi binutils-arm-none-eabi
}

command -v cmake >/dev/null || {
    print_error "cmake not found. Installing..."
    sudo apt-get install -y cmake
}

command -v python3 >/dev/null || {
    print_error "python3 not found. Installing..."
    sudo apt-get install -y python3 python3-pip
}

print_info "Dependencies OK"

# Clone/update mayhem firmware
print_step "Setting up Mayhem firmware..."

MAYHEM_DIR="$SCRIPT_DIR/build/mayhem-firmware"
if [ ! -d "$MAYHEM_DIR/.git" ]; then
    mkdir -p "$SCRIPT_DIR/build"
    cd "$SCRIPT_DIR/build"
    git clone --depth 1 https://github.com/portapack-mayhem/mayhem-firmware.git
    cd mayhem-firmware
else
    cd "$MAYHEM_DIR"
fi

# Initialize submodules
print_info "Initializing submodules..."
git submodule update --init --recursive

# Build libopencm3
print_step "Building libopencm3..."
cd "$MAYHEM_DIR/hackrf/firmware/libopencm3"

if [ ! -f "lib/libopencm3_lpc43xx.a" ]; then
    make lib -j4
    print_info "libopencm3 built successfully"
else
    print_info "libopencm3 already built"
fi

# Integrate mdk-predator
print_step "Integrating MDK-Predator..."
EXTERNAL_DIR="$MAYHEM_DIR/firmware/application/external/mdk_predator"
mkdir -p "$EXTERNAL_DIR"

# Copy files
cp -r "$SCRIPT_DIR/mdk-predator-source/app" "$EXTERNAL_DIR/"
cp -r "$SCRIPT_DIR/mdk-predator-source/src" "$EXTERNAL_DIR/"
cp -r "$SCRIPT_DIR/mdk-predator-source/include" "$EXTERNAL_DIR/"
cp "$SCRIPT_DIR/mdk-predator-source/mdk_predator.conf" "$EXTERNAL_DIR/"

# Register in external.cmake (update if not already present)
EXTERNAL_CMAKE="$MAYHEM_DIR/firmware/application/external/external.cmake"
if ! grep -q "mdk_predator" "$EXTERNAL_CMAKE"; then
    print_info "Registering MDK-Predator in external.cmake..."

    # Backup original
    cp "$EXTERNAL_CMAKE" "$EXTERNAL_CMAKE.backup"

    # Add MDK-Predator sources and app
    sed -i '1s/^/# mdk_predator auto-registered by build script\n/' "$EXTERNAL_CMAKE"
fi

# Build firmware
print_step "Building PortaPack firmware with MDK-Predator..."
cd "$MAYHEM_DIR"
mkdir -p build
cd build

cmake .. >/dev/null 2>&1
make application -j4

# Check if build succeeded
APP_FILE="$MAYHEM_DIR/firmware/application/external/mdk_predator.ppma"
if [ -f "$APP_FILE" ]; then
    print_info "Build successful!"

    # Copy output
    mkdir -p "$SCRIPT_DIR/build"
    cp "$APP_FILE" "$SCRIPT_DIR/build/"
    print_info "Output: $SCRIPT_DIR/build/mdk_predator.ppma"
else
    print_error "Build failed - application not found"
    exit 1
fi

print_step "Build complete!"
