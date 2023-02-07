// tb_tst_6502.v - testbench for test 6502 core
// 02-11-19 E. Brombaugh

`timescale 1ns/1ps

module iceMCU_tb;
    reg clk;
    reg reset;
	wire [7:0] gpio_o;
	reg [7:0] gpio_i;
	reg RX;
    wire TX;
    
    // clock source
    always
        #125 clk = ~clk;
    
    // reset
    initial
    begin

  		$dumpfile("iceMCU_tb.vcd");
		$dumpvars;

        
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
    iceMCU ucpu(
        .clk(clk),
        .gpio_o(gpio_o),        // gpio output
        .gpio_i(gpio_i),        // gpio input
        .uart_rx(RX),                // serial input
        .uart_tx(TX)                 // serial output
    );
    defparam core.RAM_TYPE = 0; // 0 => BRAM, 1 => SPRAM (UltraPlus)
endmodule
