# MDK-Predator Deployment Guide for PortaPack H4M

## Current Status

✅ **Pre-built Firmware (v2.4.0)**
- `firmware_hpro.bin` - Ready for PortaPack H4M
- Available at: `F:\!!\Downloads\FIRMWARE_mayhem_v2.4.0\`

❌ **External App Binary (.ppma)**
- Cannot be generated in this environment
- Reason: mayhem-firmware v2.4.0 has platform architecture issues that prevent application.elf from compiling
- MDK-Predator source is fully integrated in `/firmware/application/external/mdk_predator/`

## Deployment Steps

### Step 1: Flash Pre-built Firmware to PortaPack H4M

**On Windows (local):**

1. Download and install PortaPack firmware flasher (if not already done)
2. Locate `firmware_hpro.bin` from v2.4.0 release
3. Connect PortaPack H4M to USB
4. Flash firmware_hpro.bin using your chosen method:
   - Via USB bootloader
   - Via SD card if your device supports it
   - Via HackRF interface

**Verification:** PortaPack should boot normally after reboot

### Step 2: MDK-Predator Integration Status

**What's Ready:**
- ✓ Source code integrated into mayhem-firmware external app framework
- ✓ All files copied to: `firmware/application/external/mdk_predator/`
- ✓ CMake configuration complete
- ✓ All baseband modules compile successfully

**What's Blocked:**
- ✗ application.elf build fails due to:
  - fatfs_diskio.c: Missing SDCD1 driver definitions
  - gpio.hpp: Missing PAL (Port Abstraction Layer) types (ioportid_t, iopadid_t)
  - Root cause: "Gpio modify v4" commit in mayhem-firmware introduced M4-only dependencies in M0 code

**Next Steps for .ppma Generation:**

Option A (Recommended for full functionality):
- Build mayhem-firmware from source **with the GPIO platform issues fixed**
- This requires either:
  1. Using an earlier mayhem-firmware version (before "Gpio modify v4" commit)
  2. Fixing platform layer in mayhem-firmware
  3. Using Docker build if network access is available

Option B (Quick test):
- Test PortaPack H4M with standard mayhem-firmware first
- Then attempt .ppma generation on a machine where application.elf builds successfully

## Files Generated

```
/home/user/WebHacking/build/mdk-predator/build/mayhem-firmware/
├── firmware_hpro.bin (from v2.4.0 pre-built)
├── firmware/application/external/mdk_predator/ (integrated source code)
├── download_prebuilt_firmware.sh (firmware download helper)
└── PREBUILT_FIRMWARE_INTEGRATION.md (Ukrainian integration guide)
```

## Troubleshooting

**If firmware won't flash:**
- Verify USB connection
- Check firmware file is not corrupted (should be > 1MB)
- Check PortaPack is in bootloader mode

**If firmware boots but MDK-Predator not found:**
- .ppma file needs to be generated and deployed to `/APPS/` on SD card
- Currently this step is blocked by build issues
- Contact mayhem-firmware maintainers if you need to build external apps

## References

- Mayhem-firmware releases: https://github.com/portapack-mayhem/mayhem-firmware/releases
- PortaPack documentation: https://github.com/portapack-mayhem/mayhem-firmware/wiki
- Current build log: See ERROR messages in application.elf compilation

## Notes

The MDK-Predator integration is complete at the source level. Full deployment requires either:
1. Resolving mayhem-firmware's platform layer issues
2. Using a firmware version without the GPIO breaking changes
3. Building on a system with compatible ChibiOS/HAL configuration
