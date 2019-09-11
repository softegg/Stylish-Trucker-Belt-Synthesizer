#ifndef FLASHWRITER_USER_H
#define FLASHWRITER_USER_H (1)

#include "stm32f10x_type.h"
unsigned int crMask(int pin);

void setupFLASH(void);


bool flashWriteWord(u32 addr, u32 word);
bool flashErasePage(u32 addr);
bool flashErasePages(u32 addr, u16 n);
void flashLock(void);
void flashUnlock(void);

uint32_t getFlashEnd(void);
uint32_t getFlashPageSize(void);
#endif