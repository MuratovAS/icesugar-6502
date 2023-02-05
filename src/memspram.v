// memspram.v - 32k byte inferred RAM
// 03-11-18 E. Brombaugh

module memspram #(
    parameter ADDR_WIDTH = 15 //max 15
)(
    input clk,
    input sel,
    input we,
    input [ADDR_WIDTH-1:0] addr,
    input [7:0] din,
    output [7:0] dout
);
	reg [7:0] dout;
	wire [15:0] data;
	
	//SB_SPRAM256KA.ADDRESS is 14bit:
	wire [13:0] addr_sp;
	assign addr_sp = addr[ADDR_WIDTH-1:1];

    // instantiate the big RAM
	SB_SPRAM256KA mem (
		.ADDRESS(addr_sp),
		.DATAIN({din,din}),
		.MASKWREN(addr[0]?4'b1100:4'b0011),
		.WREN(we),
		.CHIPSELECT(sel),
		.CLOCK(clk),
		.STANDBY(1'b0),
		.SLEEP(1'b0),
		.POWEROFF(1'b1),
		.DATAOUT(data)
	);
    
    // pipeline the output select
    reg hilo_sel;
    always @(posedge clk)
        hilo_sel <= addr[0];
	
	always @(*)
		dout = hilo_sel ? data[15:8] : data[7:0];
endmodule
