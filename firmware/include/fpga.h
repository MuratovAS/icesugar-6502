/*
 * fpga.h - handy info about the FPGA
 * 03-04-19 E. Brombaugh
 */

#ifndef __FPGA__
#define __FPGA__


#define SYS_XTAL_FREQ   12E6

#define SYS_ROM_ADDR    0xF000
#define SYS_ROM_SIZE    0x1000

#define SYS_RAM_ADDR    0x0000
#define SYS_RAM_SIZE    0x8000

// registers
#define GPIO_DATA (*(unsigned char *) 0x8000)
#define UART_DATA (*(unsigned char *) 0xE000)
#define UART_STAT (*(unsigned char *) 0xE001)

// bits
#define UART_STAT_TXE 0b00000001
#define UART_STAT_RXF 0b00000010
#define UART_STAT_ERR 0b00000000
#define UART_STAT_IRQ 0b00000000

#endif
