/* *****************************************************************************
 * The MIT License
 *
 * Copyright (c) 2010 LeafLabs LLC.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * ****************************************************************************/
#define FLASHWRITER_c (1)

#include "flashwriter.h"

int wTransferSize;

void setupFLASH() {
    /* configure the HSI oscillator */
    if ((pRCC->CR & 0x01) == 0x00) {
        u32 rwmVal = pRCC->CR;
        rwmVal |= 0x01;
        pRCC->CR = rwmVal;
    }

    /* wait for it to come on */
    while ((pRCC->CR & 0x02) == 0x00) {}
}


bool flashErasePage(u32 pageAddr) {
    u32 rwmVal = GET_REG(FLASH_CR);
    rwmVal = FLASH_CR_PER;
    SET_REG(FLASH_CR, rwmVal);

    while (GET_REG(FLASH_SR) & FLASH_SR_BSY) {}
    SET_REG(FLASH_AR, pageAddr);
    SET_REG(FLASH_CR, FLASH_CR_START | FLASH_CR_PER);
    while (GET_REG(FLASH_SR) & FLASH_SR_BSY) {}

    /* todo: verify the page was erased */

    rwmVal = 0x00;
    SET_REG(FLASH_CR, rwmVal);

    return TRUE;
}
bool flashErasePages(u32 pageAddr, u16 n) {
    while (n-- > 0) {
        if (!flashErasePage(pageAddr + wTransferSize * n)) {
            return FALSE;
        }
    }

    return TRUE;
}

bool flashWriteWord(u32 addr, u32 word) {
    vu16 *flashAddr = (vu16 *)addr;
    vu32 lhWord = (vu32)word & 0x0000FFFF;
    vu32 hhWord = ((vu32)word & 0xFFFF0000) >> 16;

    u32 rwmVal = GET_REG(FLASH_CR);
    SET_REG(FLASH_CR, FLASH_CR_PG);

    /* apparently we need not write to FLASH_AR and can
       simply do a native write of a half word */
    while (GET_REG(FLASH_SR) & FLASH_SR_BSY) {}
    *(flashAddr + 0x01) = (vu16)hhWord;
    while (GET_REG(FLASH_SR) & FLASH_SR_BSY) {}
    *(flashAddr) = (vu16)lhWord;
    while (GET_REG(FLASH_SR) & FLASH_SR_BSY) {}

    rwmVal &= 0xFFFFFFFE;
    SET_REG(FLASH_CR, rwmVal);

    /* verify the write */
    if (*(vu32 *)addr != word) {
        return FALSE;
    }

    return TRUE;
}

void flashLock() {
    /* take down the HSI oscillator? it may be in use elsewhere */

    /* ensure all FPEC functions disabled and lock the FPEC */
    SET_REG(FLASH_CR, 0x00000080);
}

void flashUnlock() {
    /* unlock the flash */
    SET_REG(FLASH_KEYR, FLASH_KEY1);
    SET_REG(FLASH_KEYR, FLASH_KEY2);
}

// Used to create the control register masking pattern, when setting control register mode.
uint32_t crMask(uint32_t pin)
{
    uint32_t mask;
    if (pin>=8)
    {
        pin-=8;
    }
    mask = 0x0F << (pin<<2);
    return ~mask;
}

#define FLASH_SIZE_REG 0x1FFFF7E0
uint32_t getFlashEnd(void)
{
    uint16_t *flashSize = (uint16_t *) (FLASH_SIZE_REG);// Address register
    return ((uint32_t)(*flashSize & 0xffff) * 1024) + 0x08000000;
}

uint32_t getFlashPageSize(void)
{

    uint16_t *flashSize = (uint16_t *) (FLASH_SIZE_REG);// Address register
    if ((*flashSize & 0xffff) > 128)
    {
        wTransferSize = 0x800;
        return 0x800;
    }
    else
    {
        wTransferSize = 0x400;
        return 0x400;
    }
}