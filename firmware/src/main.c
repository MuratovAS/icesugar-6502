/*
 * main.c - top level 6502 C code for up5k_6502
 * 03-05-19 E. Brombaugh
 * based on example code from https://cc65.github.io/doc/customizing.html
 */
 
#include "basic.h"
#include "uart.h"
#include "main.h"

int8_t start = 0;
uint16_t last_usable_addr = 0;
uint16_t *addr;
char strbuf[180];

int main()
{
	uart_write("BOOT\r\n");
    snprintf(strbuf, sizeof(strbuf), "Hello world, 6502 SoC\r\n");
    uart_write(strbuf);

    //asm("SEI");		// disable IRQ
	//asm("CLI");		// enable IRQ

	#if defined(WDT)
        WDTDIV(240);
        WDTCOMP(200);
        WDTRST;
    #endif
 	
	snprintf(strbuf, sizeof(strbuf), "Action key:\n\r a - Test portA \n\r d - Test DMA \n\r r - CPU Reset \n\r c - View ROM \n\r m - View RAM \n\r t - Test RAM \n\r");
    uart_write(strbuf);
    while(1)
    {
        int8_t uart_rx = getchar();

        switch(uart_rx)
        {
            case 'a': // Test portA
                GPIO_DATA = getchar();
                snprintf(strbuf, sizeof(strbuf), "GPIO_DATA = ");
                uart_write(strbuf);
                printBits(sizeof(GPIO_DATA), GPIO_DATA);
                snprintf(strbuf, sizeof(strbuf), "\n\r");
                uart_write(strbuf);
                break;
            case 'r': // CPU Reset
                //cpu_reset();
                break;
            case 'c': // View ROM
                viewMemory((uint8_t*)SYS_ROM_ADDR, SYS_ROM_SIZE);
                break;
            /*case 'd': // Test DMA
                snprintf(strbuf, sizeof(strbuf), "Test DMA A(0x8000) -> B(0x8010)x8\n\r");
                uart_write(strbuf);
                viewMemory((uint8_t*)0x8000, 0x0050);
                dma_confA(MEM, (uint16_t)0x8000, 0);
                dma_confB(MEM, (uint16_t)0x8010, 7);
                dma_cmd(CONF_FLAG, true);
                dma_cmd(CONF_LOOP, false);
                dma_cmd(CONF_EN, true);
                viewMemory((uint8_t*)0x8000, 0x0050);
                break;*/
            case 'm': // View RAM
                viewMemory((uint8_t*)SYS_RAM_ADDR, SYS_RAM_SIZE);
                break;
            case 't': // Test RAM
				{ 
                int8_t free = 0;
                uint16_t *addr = &free;
                last_usable_addr = 0;
                while((uint16_t)addr < (SYS_RAM_ADDR+SYS_RAM_SIZE))
                {
                    *(addr) = (uint16_t)addr;
                    if(*(addr) != addr)
                    {
                        break;
                    }
                    last_usable_addr = (uint16_t)addr;
                    addr++;
                }
                snprintf(strbuf, sizeof(strbuf), "RAM: start = 0x%X, last usable = 0x%X, ramsize = %u\n\r",
                    (uint16_t)&start, last_usable_addr, last_usable_addr-(uint16_t)&start
                );
                uart_write(strbuf);
				}
                break;
            default:
                putchar(uart_rx);
                break;
        }
    }
    //  We should never get here!
    return (0);
}
