#include "mdk_hardware_interface.h"

/* PortaPack-compatible stub implementation */

int mdk_hardware_init(mdk_hardware_interface_t *hw) {
    if (!hw) return -1;
    hw->initialized = 1;
    return 0;
}

void mdk_i2c_write(uint8_t address, uint8_t data) {
    (void)address;
    (void)data;
}

uint8_t mdk_i2c_read(uint8_t address) {
    (void)address;
    return 0;
}

void mdk_hardware_bruteforce_start(void) {
}

void mdk_hardware_bruteforce_stop(void) {
}
