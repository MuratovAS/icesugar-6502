#include "spi.h"
#include "fpga.h"
//#include "wdt.h"


uint8_t spi_xfer_single(uint8_t cmd)
{
    SPI_DATA = cmd;
    SPI_CMD = SPI_CMD_FINISH | SPI_CMD_START;
    while((SPI_STAT & SPI_STAT_REQ) == 0)
    {
        #if defined(WDT)
            WDTRST;
        #endif
    }

    return SPI_DATA;
}

void spi_xfer(uint8_t *tx, uint8_t *rx, uint16_t tx_len, uint16_t rx_len)
{
    uint16_t i = 0;
    uint16_t len = rx_len;

    if( tx_len >= rx_len )
    {
        len = tx_len;
    }

    for(i = 0; i < len; i++)
    {
        SPI_DATA = (i < tx_len) ? tx[i] : 0x00;
        SPI_CMD = (i == (len-1)) ? SPI_CMD_FINISH | SPI_CMD_START : SPI_CMD_START;
        while((SPI_STAT & SPI_STAT_REQ) == 0)
        {
            #if defined(WDT)
                WDTRST;
            #endif
        }

        if(i < rx_len)
        {
            rx[i] = SPI_DATA;
        }
    }
}

