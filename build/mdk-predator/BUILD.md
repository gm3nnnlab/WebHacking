# MDK-Predator Build Documentation

## Overview

MDK-Predator is a comprehensive security research suite for the Mayhem-MDK platform, designed to work on the PortaPack H4M with Mayhem firmware. This document provides complete build information.

## Compiler Information

- **ARM Compiler**: arm-none-eabi-gcc 13.2.1 (15:13.2.rel1-2)
- **Host Compiler**: gcc 13.2.1
- **CMake**: 3.28.0+
- **Build System**: CMake + Make
- **Target Architecture**: ARM Cortex-M4/M0 (LPC43xx)

## Build Dependencies

### Required Packages
```
gcc-arm-none-eabi          # ARM cross-compiler
binutils-arm-none-eabi     # ARM binutils
cmake                       # Build system
python3                     # Build scripts
python3-pip                 # Python package manager
git                         # Version control
make                         # Build tool
dfu-util                    # Firmware flashing utility
ninja-build                 # Alternative build tool
liblz4-tool                 # Compression tool
libusb-1.0-0-dev           # USB development library
```

### Installation (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install -y \
  gcc-arm-none-eabi \
  binutils-arm-none-eabi \
  cmake \
  python3 \
  python3-pip \
  git \
  make \
  dfu-util \
  ninja-build \
  liblz4-tool \
  libusb-1.0-0-dev
```

### Installation (Fedora/RHEL)
```bash
sudo dnf install -y \
  arm-none-eabi-gcc-cs \
  arm-none-eabi-newlib \
  cmake \
  python3 \
  git \
  make \
  dfu-util \
  ninja-build
```

### Installation (Arch Linux)
```bash
sudo pacman -S --noconfirm \
  arm-none-eabi-gcc \
  arm-none-eabi-newlib \
  cmake \
  python3 \
  git \
  make \
  dfu-util \
  ninja-build
```

## Build Process

### Step 1: Clone Repository
```bash
git clone https://github.com/limbo111111/mdk-predator.git
cd mdk-predator
```

### Step 2: Initialize Build Directory
```bash
mkdir -p build
cd build
```

### Step 3: Clone and Setup Mayhem Firmware
```bash
git clone --depth 1 https://github.com/portapack-mayhem/mayhem-firmware.git
cd mayhem-firmware
git submodule update --init --recursive
```

### Step 4: Build libopencm3
```bash
cd hackrf/firmware/libopencm3
make lib -j4
cd ../../..
```

### Step 5: Integrate MDK-Predator
```bash
EXTERNAL_DIR="firmware/application/external/mdk_predator"
mkdir -p "$EXTERNAL_DIR"
cp -r ../../app "$EXTERNAL_DIR/"
cp -r ../../src "$EXTERNAL_DIR/"
cp -r ../../include "$EXTERNAL_DIR/"
cp ../../mdk_predator.conf "$EXTERNAL_DIR/"
```

### Step 6: Configure and Build
```bash
mkdir build
cd build
cmake ..
make application -j4
cd ../..
```

## Output Files

### Primary Output
- **mdk_predator.ppma**: PortaPack external application binary
  - Location: `mayhem-firmware/firmware/application/external/mdk_predator.ppma`
  - Size: Approximately 1-2 MB (varies with optimizations)
  - Format: PortaPack application package

### Libraries Built
- **libopencm3_lpc43xx.a**: LPC43xx hardware abstraction library
- **libmdk_predator.a**: Core MDK-Predator library

## Build Commands Summary

```bash
# Complete automated build (using provided build.sh)
chmod +x build.sh
./build.sh

# Manual step-by-step
export BUILD_DIR="$PWD/build"
export MAYHEM_DIR="$BUILD_DIR/mayhem-firmware"

# 1. Clone firmware
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
git clone --depth 1 https://github.com/portapack-mayhem/mayhem-firmware.git

# 2. Initialize submodules
cd "$MAYHEM_DIR"
git submodule update --init --recursive

# 3. Build libopencm3
cd hackrf/firmware/libopencm3
make lib -j4

# 4. Integrate mdk-predator
cd "$MAYHEM_DIR"
EXTERNAL_DIR="firmware/application/external/mdk_predator"
mkdir -p "$EXTERNAL_DIR"
cp -r /path/to/mdk-predator/app "$EXTERNAL_DIR/"
cp -r /path/to/mdk-predator/src "$EXTERNAL_DIR/"
cp -r /path/to/mdk-predator/include "$EXTERNAL_DIR/"

# 5. Build firmware
mkdir -p build
cd build
cmake ..
make application -j4
```

## Runtime Requirements

### Hardware
- PortaPack H4M with Mayhem firmware
- SD card (for app storage)
- USB connection to host machine (for deployment)

### Firmware
- Mayhem firmware (any recent version compatible with external apps)
- Sufficient flash space (typical: 1-2 MB)

### Libraries Used
- libopencm3: Hardware abstraction for LPC43xx
- ChibiOS: RTOS kernel
- Various PortaPack application framework libraries

## Build Flags and Options

### Compiler Flags
```
ARM Compiler Flags:
  -Wall -Wextra       # Enable additional warnings
  -std=c11            # C11 standard for C files
  -std=c++17          # C++17 standard for C++ files
  -mcpu=cortex-m4     # Target ARM Cortex-M4
  -mthumb             # Thumb instruction set
  -O2                 # Optimization level 2
```

## Troubleshooting

### Missing Dependencies
If you encounter missing package errors, install using:
```bash
sudo apt-get install -y [package-name]
```

### CMake Configuration Errors
```bash
# Clean and reconfigure
rm -rf build
mkdir build
cd build
cmake ..
```

### Build Failures
```bash
# Clean and rebuild
make clean
make application -j4

# For verbose output:
make VERBOSE=1 application
```

### libopencm3 Build Issues
```bash
# Rebuild libopencm3 from scratch
cd hackrf/firmware/libopencm3
make clean
make lib -j4
```

## Docker Build

A Dockerfile is provided for isolated builds:

```bash
# Build Docker image
docker build -t mdk-predator-builder -f Dockerfile.build .

# Run build in container
docker run --rm \
  -v $(pwd)/mdk-predator:/workspace/mdk-predator \
  -v $(pwd)/build:/workspace/build \
  mdk-predator-builder \
  /usr/local/bin/build-mdk-predator.sh
```

## Installation

1. Format SD card as FAT32
2. Create directory structure:
   ```
   /APPS/
   /MDK-PREDATOR/config/
   ```
3. Copy `mdk_predator.ppma` to `/APPS/`
4. Copy `mdk_predator.conf` to `/MDK-PREDATOR/config/` (optional)
5. Insert SD card into PortaPack
6. Launch from Apps menu

## Source Code Structure

```
mdk-predator/
├── app/                  # PortaPack application UI/entry point
│   ├── main.cpp         # Application entry point
│   ├── mdk_predator_app.cpp # Main application logic
│   └── UI_THEME.hpp     # UI theme definitions
├── src/                 # Core functionality
│   ├── automotive/      # Key fob and rolling code analysis
│   │   ├── key_fob_analyzer.c
│   │   └── rolling_code_tester.c
│   ├── wireless/        # WiFi, Bluetooth, SubGHz modules
│   │   ├── wifi_analyzer.c
│   │   ├── bluetooth_analyzer.c
│   │   └── subghz_analyzer.c
│   ├── crypto/          # Cryptographic analysis
│   │   └── crypto_analyzer.c
│   └── mdk_predator.c   # Core functionality
├── include/             # Header files
├── Makefile            # Traditional build (for ARM lib)
└── scripts/            # Build helper scripts
```

## Performance Notes

- Build time: 15-20 minutes (including firmware baseline)
- Binary size: ~1-2 MB for .ppma file
- RAM usage during build: 2-4 GB
- Disk space required: ~3-5 GB

## Version Information

- **MDK-Predator Version**: Latest (check repository)
- **Mayhem Firmware Compatibility**: v1.60+
- **PortaPack Hardware**: H4M
- **ARM Toolchain Version**: GCC 13.2.1
