// tb_tst_6502.v - testbench for test 6502 core
// 02-11-19 E. Brombaugh

`timescale 1ns/1ps

`include "src/top.v"

module testbench;
    reg clk;
    reg reset;
	wire [7:0] gpio_o;
	reg [7:0] gpio_i;
	reg RX;
    wire TX;
    
	always #5 clk = (clk === 1'b0);
    
    // reset
    initial
    begin

  		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);

        // init regs
        clk = 1'b0;
        reset = 1'b1;
        RX = 1'b1;
        
        // release reset
        #1000
        reset = 1'b0;

        // stop after 1 sec
		#1000000 $finish;
    end
    
    // Unit under test
    top uut(
        .clk(clk),
     
        .uart_rxd(RX),                // serial input
        .uart_txd(TX),                 // serial output
		
        .LED_B (gpio_o[0]), 
        .LED_R (gpio_o[1]), 
        .LED_G (gpio_o[2])

    );
    defparam uut.core.RAM_TYPE = 1; // 0 => BRAM, 1 => SPRAM (UltraPlus)
endmodule
