/*
 * fpga.h - handy info about the FPGA
 * 03-04-19 E. Brombaugh
 */

#ifndef __FPGA__
#define __FPGA__


#define SYS_XTAL_FREQ   12E6

#define SYS_ROM_ADDR    0xE000
#define SYS_ROM_SIZE    0x2000

#define SYS_RAM_ADDR    0x0000
#define SYS_RAM_SIZE    0x8000

// registers
#define GPIO_DATA (*(unsigned char *) 0x8000)
#define UART_DATA (*(unsigned char *) 0x8010)
#define UART_STAT (*(unsigned char *) 0x8011)

// bits
#define UART_STAT_TXE 0b00000001
#define UART_STAT_RXF 0b00000010
#define UART_STAT_ERR 0b00000000
#define UART_STAT_IRQ 0b00000000



// registers
#define SPI_DATA (*(unsigned char *) 0x8020)
#define SPI_CMD (*(unsigned char *) 0x8021)
#define SPI_STAT (*(unsigned char *) 0x8021)

// bits
#define SPI_CMD_START   0b00000001
#define SPI_CMD_FINISH  0b00000010
#define SPI_STAT_REQ    0b10000000
#define SPI_STAT_ERR    0b01000000

#endif
