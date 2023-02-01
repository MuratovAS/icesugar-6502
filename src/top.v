// u4k_6502_top.v - top level for tst_6502 in u4k
// 03-02-19 E. Brombaugh

`include "src/iceMCU.v"

module top(
    // serial
    input uart_rxd,
    output uart_txd,
	
	// LED
	output LED_B, LED_R, LED_G,
	
	input SW_1,
	input SW_2,
	input SW_3,
	input SW_4,

	output DEBUG_0,
	output DEBUG_1,
	output DEBUG_2,
	output DEBUG_3,
	output DEBUG_4,
	output DEBUG_5,
	output DEBUG_6,
	output DEBUG_7

);
    wire [7:0] gpio_o;	// output
    wire [7:0] gpio_i;	// input

	// clock generator
	wire clk_48;

	SB_HFOSC inthosc (
		.CLKHFPU(1'b1),
		.CLKHFEN(1'b1),
		.CLKHF(clk_48)
	);
	
	// clock divider generates 50% duty 12MHz clock
	reg [1:0] cnt;
	initial
        cnt <= 2'b00;
        
	always @(posedge clk_48)
	begin
        cnt <= cnt + 2'b01;
	end
    wire clk = cnt[1];
	
	// reset generator waits > 10us
	reg [7:0] reset_cnt;
	reg reset;
	initial
        reset_cnt <= 8'h00;
    
	always @(posedge clk)
	begin
		if(reset_cnt != 8'hff)
        begin
            reset_cnt <= reset_cnt + 8'h01;
            reset <= 1'b1;
        end
        else
            reset <= 1'b0;
	end
    
	// test unit
	iceMCU uut(
		.clk(clk),
		.reset(reset),
		
		.gpio_o(gpio_o),
		.gpio_i(gpio_i),
    
        .RX(uart_rxd),
        .TX(uart_txd),
    
        .CPU_IRQ(DEBUG_0)
	);
    
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

endmodule
