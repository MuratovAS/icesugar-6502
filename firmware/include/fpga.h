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


// registers
#define ACIA_STAT (*(unsigned char *) 0xE000)
#define ACIA_CTRL (*(unsigned char *) 0xE000)
#define ACIA_DATA (*(unsigned char *) 0xE001)

// bits
#define ACIA_STAT_RXF 0x01
#define ACIA_STAT_TXE 0x02
#define ACIA_STAT_ERR 0x10
#define ACIA_STAT_IRQ 0x80

#define ACIA_CTRL_CDIVSEL_MASK 0x03
#define ACIA_CTRL_CDIVSEL_1 0x00
#define ACIA_CTRL_CDIVSEL_MR 0x03

#define ACIA_CTRL_TXIE_MASK 0x20
#define ACIA_CTRL_TXIE_DIS 0x00
#define ACIA_CTRL_TXIE_ENA 0x20

#define ACIA_CTRL_RXIE_MASK 0x80
#define ACIA_CTRL_RXIE_DIS 0x00
#define ACIA_CTRL_RXIE_ENA 0x80

#endif
