#include "fpga.h"
#include "uart.h"
//#include "wdt.h"

int putchar(int c)
{
    //while ((UART_STAT & UART_STAT_TXE))
    {
        #if defined(WDT)
            WDTRST;
        #endif
    }
    UART_DATA = c;
    return c;
}

int getchar()
{
    //while (!(UART_STAT & UART_STAT_RXF))
    {
        #if defined(WDT)
            WDTRST;
        #endif
    }
    return UART_DATA;
}

void uart_write(char *str)
{
    uint16_t i = 0;

    for(i = 0; str[i] != 0; i++)
    {
        putchar(str[i]);
    }
}