# MDK-Predator Build Artifacts

This directory contains all artifacts needed to build and deploy MDK-Predator, a comprehensive security research suite for the PortaPack H4M with Mayhem firmware.

## Contents

```
.
├── build.sh                    # Automated build script for Linux/macOS
├── Dockerfile                  # Complete build environment for Docker
├── BUILD.md                    # Detailed build documentation
├── patches/                    # Unified diff patches for modifications
│   └── 001-add-mdk-predator-to-external.patch
├── mdk-predator-source/       # Complete MDK-Predator source code
└── README.md                  # This file
```

## Quick Start

### Option 1: Automated Build (Linux/macOS)

```bash
chmod +x build.sh
./build.sh
```

Output will be in `build/mdk_predator.ppma`

### Option 2: Docker Build

```bash
docker build -t mdk-predator-builder -f Dockerfile .
docker run --rm \
  -v $(pwd):/workspace \
  mdk-predator-builder \
  bash -c "cd /workspace && ./build.sh"
```

## Build Requirements

### Native Build
- ARM GCC toolchain (arm-none-eabi-gcc 13.2.1+)
- CMake 3.16+
- Python 3.7+
- Git
- Make
- 3-5 GB disk space
- 2-4 GB RAM during build

### Docker Build
- Docker (any recent version)
- Internet connection for pulling Ubuntu base image
- 5 GB available disk space

## Build Process Overview

1. **Clone Mayhem Firmware** - Downloads PortaPack Mayhem firmware source
2. **Initialize Submodules** - Sets up libopencm3 and HackRF dependencies
3. **Build libopencm3** - Compiles hardware abstraction library
4. **Integrate MDK-Predator** - Registers application with Mayhem firmware
5. **Compile Firmware** - Builds complete application binary
6. **Generate .ppma** - Creates PortaPack application package

## Compiler Specifications

- **Compiler**: GCC ARM None-EABI 13.2.1
- **Standard**: C11 for C code, C++17 for C++ code
- **Optimization**: -O2 (balance of speed and size)
- **Architecture**: ARM Cortex-M4/M0 (LPC43xx)
- **Target**: PortaPack H4M

## Output Binary

**File**: `mdk_predator.ppma`  
**Type**: PortaPack external application package  
**Size**: ~1-2 MB  
**Format**: Binary application file for PortaPack firmware

### Installation

1. Format SD card as FAT32
2. Create directory structure:
   ```
   /APPS/
   /MDK-PREDATOR/config/
   ```
3. Copy `mdk_predator.ppma` to `/APPS/`
4. Insert SD card into PortaPack
5. Launch from Apps menu

## Troubleshooting

### Build Fails with Missing Headers
- Ensure all dependencies are installed
- Check `BUILD.md` for system-specific installation commands

### Missing arm-none-eabi-gcc
```bash
# Ubuntu/Debian
sudo apt-get install gcc-arm-none-eabi

# Fedora/RHEL  
sudo dnf install arm-none-eabi-gcc-cs

# Arch/Manjaro
sudo pacman -S arm-none-eabi-gcc
```

### Out of Disk Space During Build
- Clean intermediate files: `rm -rf build/mayhem-firmware/build`
- Ensure 5 GB free space before rebuilding

### Compiler Version Mismatch Warning
- Doesn't affect builds, just informational
- Official builds use GCC 9.2.1 but 13.2.1 also works

## Project Information

- **Repository**: https://github.com/limbo111111/mdk-predator
- **Firmware**: Portapack-Mayhem https://github.com/portapack-mayhem/mayhem-firmware
- **Hardware**: PortaPack H4M module
- **Build Date**: 2026-07-11

## Patches Applied

See `patches/` directory for unified diff files showing modifications to Mayhem firmware's `external.cmake` file to integrate MDK-Predator.

## Support

For issues and questions:
1. Check `BUILD.md` for detailed troubleshooting
2. Review build logs for error messages
3. Verify all dependencies are correctly installed
4. Check available disk space and RAM

## License

MDK-Predator and its build system are provided as-is. Refer to project repositories for license details.
