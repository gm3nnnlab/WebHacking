# Complete Guide: Building MDK-Predator .ppma on Another Machine

## Overview

This guide walks you through generating the `mdk_predator.ppma` file on a different machine (Linux/Mac) where mayhem-firmware builds successfully, then deploying it to PortaPack H4M.

**Timeline:** 30-60 minutes (most time is build compilation)

---

## What You'll Get

After following this guide:
- ✅ `mdk_predator.ppma` - External app binary for PortaPack
- ✅ Ready for deployment to SD card
- ✅ MDK-Predator will appear in PortaPack's "External Apps" menu

---

## Part 1: Prepare on This Machine (Remote Session)

### 1.1 Get the Files

Everything you need is already in `/home/user/WebHacking/`:

```
/home/user/WebHacking/
├── BUILD_ON_ANOTHER_MACHINE.md         ← Detailed build instructions
├── build_mdk_predator.sh               ← Automated build script
├── mdk_predator_source.tar.gz         ← MDK-Predator source (28 KB)
└── build/mdk-predator/build/mayhem-firmware/firmware/application/external/mdk_predator/
    └── [Full source tree]
```

### 1.2 Download Files for Transfer

Choose ONE of these methods:

**Method A: Via tarball (recommended)**
```bash
# All MDK-Predator source in one file
cp /home/user/WebHacking/mdk_predator_source.tar.gz ~/Downloads/
cp /home/user/WebHacking/BUILD_ON_ANOTHER_MACHINE.md ~/Downloads/
cp /home/user/WebHacking/build_mdk_predator.sh ~/Downloads/
```

**Method B: Direct folder copy**
```bash
# Copy entire source tree
cp -r /home/user/WebHacking/build/mdk-predator/build/mayhem-firmware/firmware/application/external/mdk_predator ~/Downloads/
```

---

## Part 2: Build on Another Machine (Linux/Mac)

### 2.1 Clone Mayhem-Firmware (v2.3.0 recommended)

On your build machine:

```bash
# For safest build (v2.3.0 - before GPIO issues):
git clone --branch v2.3.0 --depth 1 https://github.com/portapack-mayhem/mayhem-firmware.git
cd mayhem-firmware

# Initialize all submodules
git submodule update --init --recursive
```

⚠️ **Note:** v2.3.0 is ~2.5 GB. If you prefer latest, use:
```bash
git clone https://github.com/portapack-mayhem/mayhem-firmware.git
cd mayhem-firmware
```

### 2.2 Install Build Tools

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y \
  gcc-arm-embedded \
  binutils-arm-embedded \
  cmake \
  python3 \
  git
```

**macOS:**
```bash
brew install arm-none-eabi-gcc cmake
```

### 2.3 Add MDK-Predator Source

**Option A: From tarball**
```bash
cd mayhem-firmware/firmware/application/external
tar -xzf /path/to/mdk_predator_source.tar.gz
# Creates: mdk_predator/ directory
```

**Option B: From copied folder**
```bash
cp -r /path/to/mdk_predator mayhem-firmware/firmware/application/external/
```

### 2.4 Register in Build System

Edit `mayhem-firmware/firmware/application/external/external.cmake`:

**A) Find `set(EXTCPPSRC` section and add at the beginning:**

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
	# ... rest of file continues ...
)
```

**B) Find `set(EXTAPPLIST` section and add at the beginning:**

```cmake
set(EXTAPPLIST
	mdk_predator
	afsk_rx
	calculator
	# ... rest of list continues ...
)
```

**C) Add at end of file:**

```cmake
include_directories(external/mdk_predator/include)
include_directories(external/mdk_predator/src)
include_directories(external/mdk_predator/hal)
```

### 2.5 Build (Automated)

Use the provided build script:

```bash
cd mayhem-firmware
cp /path/to/build_mdk_predator.sh .
chmod +x build_mdk_predator.sh
./build_mdk_predator.sh
```

**Or build manually:**

```bash
cd mayhem-firmware
mkdir -p build
cd build

cmake -DARM_TOOLCHAIN_DIR=/usr \
      -DCMAKE_TOOLCHAIN_FILE=../toolchain/arm.cmake \
      -DBUILD_SHARED_LIBS=FALSE \
      ..

make -j4 application.bin

# Watch for: [100%] Built target application
```

**Build time:** 10-30 minutes depending on machine

### 2.6 Verify Success

```bash
ls -lh mayhem-firmware/build/firmware/application/mdk_predator.ppma

# Output should show ~30-35 KB file:
# -rw-r--r-- 1 user user 32K Jul 11 13:40 mdk_predator.ppma
```

---

## Part 3: Deploy to PortaPack

### 3.1 Get the .ppma File

From the build machine, copy:
```
mayhem-firmware/build/firmware/application/mdk_predator.ppma
```

### 3.2 Prepare SD Card

**On a machine with PortaPack SD card reader:**

```bash
# Mount SD card
# On Linux, it usually appears in /media/username/

# Create APPS directory if needed
mkdir -p /media/username/sdcard/APPS

# Copy .ppma file
cp mdk_predator.ppma /media/username/sdcard/APPS/

# Verify
ls -la /media/username/sdcard/APPS/
```

### 3.3 Insert into PortaPack

1. **Safely eject SD card**
   ```bash
   sudo eject /media/username/sdcard/
   ```

2. **Insert card into PortaPack H4M SD slot**

3. **Power on PortaPack**

4. **Navigate to Applications:**
   - Press Menu button
   - Select **Applications** or **Apps**
   - Look for **MDK-Predator** in External Apps list
   - Select and press OK to launch

### 3.4 Verify It Works

✅ MDK-Predator should appear in the apps menu
✅ Should launch without errors
✅ UI should display main menu with analysis options

---

## Troubleshooting

### Build Fails

**Error:** `add_subdirectory given source "hackrf/firmware" which is not an existing directory`
- **Cause:** Missing submodules
- **Solution:** Run `git submodule update --init --recursive`

**Error:** `arm-none-eabi-gcc: command not found`
- **Cause:** Toolchain not installed
- **Solution:** 
  - Ubuntu: `sudo apt install gcc-arm-embedded`
  - macOS: `brew install arm-none-eabi-gcc`

**Error:** `undefined reference to _sbrk` or GPIO errors
- **Cause:** Using v2.4.0 with platform issues
- **Solution:** Use v2.3.0 instead

### .ppma File Not Created

**Check for errors:**
```bash
cd build
tail -200 build.log | grep -i error
```

**Common issues:**
- CMake configuration failed (see config errors above)
- application.elf build failed (check build.log)
- export_external_apps.py error (check permissions)

### PortaPack Doesn't Show MDK-Predator

1. **Verify file location:**
   ```bash
   ls -la /APPS/mdk_predator.ppma
   # Must be exactly this case and location
   ```

2. **Check SD card is mounted properly**

3. **Try power cycle of PortaPack**

4. **Verify firmware compatibility:**
   - Should work with v2.4.0 firmware_hpro.bin
   - Earlier versions also compatible

---

## Files You Have Available

In `/home/user/WebHacking/`:

| File | Purpose |
|------|---------|
| `mdk_predator_source.tar.gz` | Complete MDK-Predator source (28 KB) |
| `BUILD_ON_ANOTHER_MACHINE.md` | Detailed step-by-step guide |
| `build_mdk_predator.sh` | Automated build script |
| `DEPLOYMENT_GUIDE.md` | Firmware flashing instructions |
| `STATUS_SUMMARY.md` | Complete project status |

---

## Summary of Steps

1. **This machine:** Copy files to transfer
2. **Build machine:** Clone mayhem-firmware v2.3.0
3. **Build machine:** Add MDK-Predator source
4. **Build machine:** Run build script (10-30 min)
5. **Build machine:** Get `mdk_predator.ppma` file
6. **SD card machine:** Copy to `/APPS/` directory
7. **PortaPack:** Power on and verify

---

## Expected Outcome

| Component | Status |
|-----------|--------|
| Pre-built firmware (firmware_hpro.bin) | ✅ Ready now |
| MDK-Predator source code | ✅ Integrated |
| Build on v2.3.0 | ✅ Should succeed |
| .ppma generation | ✅ Automated |
| PortaPack deployment | ✅ Simple copy to SD |

---

## Getting Help

If you hit issues:

1. **Check mayhem-firmware README:**
   https://github.com/portapack-mayhem/mayhem-firmware

2. **Review build log:**
   ```bash
   tail -100 build/build.log
   ```

3. **Verify ARM toolchain:**
   ```bash
   arm-none-eabi-gcc --version
   arm-none-eabi-g++ --version
   ```

4. **Check git status:**
   ```bash
   git log --oneline | head -5
   git submodule status
   ```

---

## Next After Successful Build

1. ✅ Transfer mdk_predator.ppma to PortaPack SD card
2. ✅ Flash pre-built firmware_hpro.bin to PortaPack (if not done)
3. ✅ Insert SD card and power on
4. ✅ Access Applications → External Apps → MDK-Predator

**All done!** You'll have a fully functional MDK-Predator deployment on PortaPack H4M.
