#!/bin/bash
# Quick build script for MDK-Predator .ppma on another machine
# Run this in mayhem-firmware checkout after integrating MDK-Predator source

set -e

echo "=== MDK-Predator Build Script ==="
echo ""

# Check prerequisites
echo "Checking prerequisites..."
if ! command -v arm-none-eabi-gcc &> /dev/null; then
    echo "❌ arm-none-eabi-gcc not found. Install with:"
    echo "   Ubuntu/Debian: sudo apt install gcc-arm-embedded"
    echo "   macOS: brew install arm-none-eabi-gcc"
    exit 1
fi

if ! command -v cmake &> /dev/null; then
    echo "❌ cmake not found. Install with:"
    echo "   Ubuntu/Debian: sudo apt install cmake"
    echo "   macOS: brew install cmake"
    exit 1
fi

echo "✓ arm-none-eabi-gcc version: $(arm-none-eabi-gcc --version | head -1)"
echo "✓ cmake version: $(cmake --version | head -1)"
echo ""

# Verify MDK-Predator source exists
if [ ! -d "firmware/application/external/mdk_predator" ]; then
    echo "❌ Error: MDK-Predator source not found at firmware/application/external/mdk_predator"
    echo "Please copy mdk_predator source directory and try again"
    exit 1
fi

echo "✓ MDK-Predator source found"
echo ""

# Create build directory
if [ ! -d "build" ]; then
    echo "Creating build directory..."
    mkdir -p build
fi

cd build

# Configure
echo "Configuring build..."
cmake -DARM_TOOLCHAIN_DIR=/usr \
      -DCMAKE_TOOLCHAIN_FILE=../toolchain/arm.cmake \
      -DBUILD_SHARED_LIBS=FALSE \
      .. > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ CMake configuration failed"
    echo "Check that submodules are initialized: git submodule update --init --recursive"
    exit 1
fi

echo "✓ Build configured"
echo ""

# Build application.bin (which generates mdk_predator.ppma)
echo "Building application.bin (this takes 10-30 minutes)..."
echo "Progress: "
make -j4 application.bin 2>&1 | tee build.log | grep -E "^\[|Built target|Error|error"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo ""
    echo "❌ Build failed. See build.log for details"
    tail -50 build.log
    exit 1
fi

echo ""
echo "=== Build Complete ==="
echo ""

# Verify .ppma was created
if [ -f "firmware/application/mdk_predator.ppma" ]; then
    SIZE=$(stat -f%z "firmware/application/mdk_predator.ppma" 2>/dev/null || stat -c%s "firmware/application/mdk_predator.ppma")
    echo "✓ mdk_predator.ppma created ($(numfmt --to=iec-i --suffix=B $SIZE 2>/dev/null || echo "${SIZE} bytes"))"
    echo ""
    echo "📦 Output file:"
    echo "   firmware/application/mdk_predator.ppma"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Copy mdk_predator.ppma to PortaPack SD card /APPS/ directory"
    echo "   2. Insert SD card into PortaPack"
    echo "   3. Navigate: Applications → External Apps → MDK-Predator"
    echo ""
    exit 0
else
    echo "❌ .ppma file not found after build"
    echo "Check firmware/application/ directory:"
    ls -la firmware/application/*.ppma 2>/dev/null || echo "No .ppma files found"
    exit 1
fi
