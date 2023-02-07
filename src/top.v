// u4k_6502_top.v - top level for tst_6502 in u4k
// 03-02-19 E. Brombaugh

`include "src/iceMCU.v"

module top(
    // uart
    input uart_rxd,
    output uart_txd,
	
	// spi
	output spi_sclk,
	output spi_mosi,
	input spi_miso,
	output spi_cs,

	// LED
	output LED_B, LED_R, LED_G,
	input [3:0] SW,
	output [7:0] DEBUG

);
    wire [7:0] gpio_o;	// output
    wire [7:0] gpio_i;	// input

	// clock generator
	wire clk_48m;
	wire clk_12m;
	
	//internal oscillators seen as modules
	//Source = 48MHz, CLKHF_DIV = 2’b00 : 00 = div1, 01 = div2, 10 = div4, 11 = div8 ; Default = “00”
	SB_HFOSC #(.CLKHF_DIV("0b10")) SB_HFOSC_inst (
		.CLKHFEN(32'b1),
		.CLKHFPU(32'b1),
		.CLKHF(clk_12m)
	);

	//10khz used for low power applications (or sleep mode)
	/*SB_LFOSC SB_LFOSC_inst(
		.CLKLFEN(1),
		.CLKLFPU(1),
		.CLKLF(clk_10k)
	);*/
	
	// toolchain-ice40/bin/icepll
	/*SB_PLL40_CORE #(
      .FEEDBACK_PATH("SIMPLE"),
      .PLLOUT_SELECT("GENCLK"),
      .DIVR(4'b0000),
      .DIVF(7'b0001111),
      .DIVQ(3'b101),
      .FILTER_RANGE(3'b100),
    ) SB_PLL40_CORE_inst (
      .RESETB(1'b1),
      .BYPASS(1'b0),
      .PLLOUTCORE(clk_48m),
      .REFERENCECLK(clk_12m)
   );*/

	//rx
	wire	txpin, rxpin;
	wire	rxpinmeta1,c_rxpinmeta1;
	SB_IO #( .PIN_TYPE(6'b000000)) // NO_OUTPUT/INPUT_REGISTERED
	IO_rx     ( .PACKAGE_PIN(uart_rxd), .INPUT_CLK(clk_12m),  .D_IN_0(rxpinmeta1) );
	SB_LUT4 #( .LUT_INIT(16'haaaa))
		cmb( .O(c_rxpinmeta1), .I3(1'b0), .I2(1'b0), .I1(1'b0), .I0(rxpinmeta1));
	SB_DFF metareg( .Q(rxpin), .C(clk_12m), .D(c_rxpinmeta1));
	//tx
	SB_IO #( .PIN_TYPE(6'b011111)) // OUTPUT_REGISTERED_INVERTED/INPUT_LATCH
		IO_tx( .PACKAGE_PIN(uart_txd), .OUTPUT_CLK(clk_12m), .D_OUT_0(txpin) );

	// RGB LED Driver from top 3 bits of gpio
	SB_RGBA_DRV #(
		.CURRENT_MODE("0b1"),
		.RGB0_CURRENT("0b000111"),
		.RGB1_CURRENT("0b000111"),
		.RGB2_CURRENT("0b000111")
	) RGBA_DRIVER (
		.CURREN(1'b1),
		.RGBLEDEN(1'b1),
		.RGB0PWM(~gpio_o[7]),
		.RGB1PWM(~gpio_o[6]),
		.RGB2PWM(~gpio_o[5]),
		.RGB0(LED_B),
		.RGB1(LED_R),
		.RGB2(LED_G)
	);

	// core unit
	iceMCU core(
		.clk(clk_12m),
		
		.gpio_o(gpio_o),
		.gpio_i(gpio_i),
    
        .uart_rx(rxpin),
        .uart_tx(txpin),
		.spi_sclk(spi_sclk),
		.spi_mosi(spi_mosi),
		.spi_miso(spi_miso),
		.spi_cs(spi_cs),

		.debug(DEBUG)
	);
    defparam core.RAM_TYPE = 1; // 0 => BRAM, 1 => SPRAM (UltraPlus)

endmodule
