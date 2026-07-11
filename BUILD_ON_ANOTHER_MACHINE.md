# Building MDK-Predator .ppma on Another Machine

This guide allows you to generate `mdk_predator.ppma` on a different machine (Linux/Mac) where mayhem-firmware builds successfully.

## Requirements

**On the build machine:**
- Linux (Ubuntu 20.04+ recommended) or macOS
- ARM embedded toolchain: `sudo apt install gcc-arm-embedded binutils-arm-embedded`
- CMake 3.13+: `sudo apt install cmake`
- Git
- Python 3

**Recommended:** Use mayhem-firmware v2.3.0 or earlier (before "Gpio modify v4" commit)

## Step 1: Clone Mayhem-Firmware

```bash
# Choose ONE version (v2.3.0 is safest for external app building)
git clone --branch v2.3.0 --depth 1 https://github.com/portapack-mayhem/mayhem-firmware.git
cd mayhem-firmware

# OR if you prefer latest with potential fixes:
# git clone https://github.com/portapack-mayhem/mayhem-firmware.git
# cd mayhem-firmware
```

## Step 2: Integrate MDK-Predator Source

### Option A: Copy from this repository
If you have access to the source files:

```bash
# Copy MDK-Predator to external apps directory
cp -r /path/to/WebHacking/build/mdk-predator/build/mayhem-firmware/firmware/application/external/mdk_predator \
   firmware/application/external/
```

### Option B: Use pre-integrated version (v2.4.0 structure)
The MDK-Predator source is already in the repository at:
```
/home/user/WebHacking/build/mdk-predator/build/mayhem-firmware/firmware/application/external/mdk_predator/
```

Copy this entire directory to your mayhem-firmware build machine.

## Step 3: Register MDK-Predator in Build System

Edit `firmware/application/external/external.cmake` and add to the `EXTCPPSRC` section (at the beginning):

```cmake
set(EXTCPPSRC
	#mdk_predator security research suite
	external/mdk_predator/app/main.cpp
	external/mdk_predator/app/mdk_predator_app.cpp
	external/mdk_predator/src/mdk_predator.c
	external/mdk_predator/src/mdk_hardware_interface.cpp
	external/mdk_predator/src/mdk_hardware_interface_portapack.cpp
	external/mdk_predator/src/automotive/key_fob_analyzer.c
	external/mdk_predator/src/automotive/rolling_code_tester.c
	external/mdk_predator/src/wireless/wifi_analyzer.c
	external/mdk_predator/src/wireless/bluetooth_analyzer.c
	external/mdk_predator/src/wireless/subghz_analyzer.c
	external/mdk_predator/src/crypto/crypto_analyzer.c
	external/mdk_predator/hal/hal.c

	#afsk_rx   16 byte
	external/afsk_rx/main.cpp
	# ... rest of existing apps ...
)
```

Also add to `EXTAPPLIST`:

```cmake
set(EXTAPPLIST
	mdk_predator
	afsk_rx
	calculator
	# ... rest of existing apps ...
)
```

And at the end of the file, add:

```cmake
include_directories(external/mdk_predator/include)
include_directories(external/mdk_predator/src)
include_directories(external/mdk_predator/hal)
```

## Step 4: Configure and Build

```bash
# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake -DARM_TOOLCHAIN_DIR=/usr \
      -DCMAKE_TOOLCHAIN_FILE=../toolchain/arm.cmake \
      -DBUILD_SHARED_LIBS=FALSE \
      ..

# Build (this will take 10-30 minutes)
make -j4 application.bin 2>&1 | tee build.log

# Watch for completion - should end with:
# [100%] Built target application
```

**If build succeeds:**
```bash
# Verify .ppma file was created
ls -lh firmware/application/mdk_predator.ppma
```

**If build fails:**
- Check `build.log` for errors
- Common issues:
  - Missing arm-none-eabi-gcc: `apt install gcc-arm-embedded`
  - Missing Python modules: `pip install intelhex`
  - ChibiOS submodule not initialized: `git submodule update --init --recursive`

## Step 5: Extract .ppma File

Once `application.bin` builds successfully:

```bash
# The .ppma file is automatically generated during build
cp firmware/application/mdk_predator.ppma /path/to/transfer/

# Verify file size (should be 20-40 KB)
ls -lh firmware/application/mdk_predator.ppma
```

## Step 6: Deploy to PortaPack

### Transfer .ppma to PortaPack SD Card

**On the machine with PortaPack SD card:**

1. Insert PortaPack SD card into card reader
2. Mount the SD card (on Linux: `/media/username/sdcard/`)
3. Create directory if needed:
   ```bash
   mkdir -p /media/username/sdcard/APPS
   ```

4. Copy the .ppma file:
   ```bash
   cp mdk_predator.ppma /media/username/sdcard/APPS/
   ```

5. Safely eject SD card:
   ```bash
   sudo eject /media/username/sdcard/
   ```

6. Insert SD card back into PortaPack

### Verify on PortaPack

1. Power on PortaPack with firmware_hpro.bin (v2.4.0 pre-built)
2. Navigate: **Applications** → **External Apps** or **Apps**
3. Look for **MDK-Predator** in the list
4. Select and run to verify it works

## Troubleshooting

### Build fails at application.elf
- You're likely on v2.4.0 or later with the GPIO issue
- **Solution:** Try v2.3.0 or earlier (before "Gpio modify v4" commit)
- Check commit: `git log --oneline | grep -i gpio`

### .ppma file not generated
- Check `build.log` for errors in export_external_apps.py
- Verify application.elf compiled successfully
- Run: `make application 2>&1 | tail -50`

### PortaPack doesn't show MDK-Predator
- Verify .ppma file is in `/APPS/` directory (case-sensitive)
- Verify firmware is v2.4.0 or compatible
- Try power cycle of PortaPack
- Check SD card integrity

### Can't find arm-none-eabi-gcc
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install gcc-arm-embedded

# macOS
brew install arm-none-eabi-gcc
```

## File Locations

On the build machine after successful build:

```
mayhem-firmware/
├── build/
│   ├── firmware/application/
│   │   ├── application.elf (compiled executable)
│   │   ├── application.bin (firmware binary)
│   │   └── mdk_predator.ppma ← THIS IS WHAT YOU NEED
│   └── build.log (build output)
└── firmware/application/external/mdk_predator/ (source files)
```

## What's in mdk_predator.ppma

The .ppma file is a PortaPack Mayhem Application binary containing:
- MDK-Predator UI frontend (runs on M0 processor)
- All analysis modules (automotive, wireless, crypto)
- Hardware interface layer for PortaPack

Size: ~30-35 KB (must be < 32 KB to fit)

## Next Steps After .ppma Generation

1. **Transfer .ppma to SD card** (Step 6 above)
2. **Flash firmware_hpro.bin** to PortaPack (if not already done)
3. **Deploy .ppma to /APPS/** directory
4. **Boot PortaPack** and verify MDK-Predator appears in Applications

## References

- Mayhem-Firmware: https://github.com/portapack-mayhem/mayhem-firmware
- PortaPack H4M Wiki: https://github.com/portapack-mayhem/mayhem-firmware/wiki
- External Apps Guide: https://github.com/portapack-mayhem/mayhem-firmware/discussions/categories/external-applications
- MDK-Predator: Security research toolkit for RF analysis

## Support

If build fails on your machine:

1. Check mayhem-firmware README for latest build requirements
2. Review your `build.log` for specific error messages
3. Verify arm toolchain version: `arm-none-eabi-gcc --version`
4. Try clean rebuild: `cd build && rm -rf * && cmake ... && make -j4`

---

**Build Time:** 10-30 minutes depending on machine  
**Storage Needed:** ~5 GB for checkout + build  
**Network:** Initial clone only
