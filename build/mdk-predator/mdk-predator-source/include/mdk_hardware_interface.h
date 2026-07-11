/*
 * MDK Hardware Interface Header
 * Provides abstraction layer for hardware-specific operations
 */

#ifndef __MDK_HARDWARE_INTERFACE_H__
#define __MDK_HARDWARE_INTERFACE_H__

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Hardware interface class for PortaPack */
typedef struct {
    uint8_t initialized;
    void (*write_fn)(uint8_t addr, uint8_t val);
    uint8_t (*read_fn)(uint8_t addr);
} mdk_hardware_interface_t;

/* Initialize hardware interface */
int mdk_hardware_init(mdk_hardware_interface_t *hw);

/* I2C write operation */
void mdk_i2c_write(uint8_t address, uint8_t data);

/* I2C read operation */
uint8_t mdk_i2c_read(uint8_t address);

/* Hardware-accelerated brute force support (stub for now) */
void mdk_hardware_bruteforce_start(void);
void mdk_hardware_bruteforce_stop(void);

#ifdef __cplusplus
}
#endif

#endif /* __MDK_HARDWARE_INTERFACE_H__ */
