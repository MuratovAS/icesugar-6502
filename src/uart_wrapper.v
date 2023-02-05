// uart_wrapper.v - strippped-down version of MC6850 ACIA wrapped around FOSS UART
// 03-02-19 E. Brombaugh

`include "src/uart.v"

module uart_wrapper#(
	parameter UART_CLK = 12000000,
	parameter BAUD_RATE = 115200
)(
	input clk,				// system clock
	input rst,				// system reset
	input cs,				// chip select
	input we,				// write enable
	input [1:0] addr,		// addr bus
	input [7:0] din,		// data bus input
	output [7:0] dout,		// data bus output
	input rx,				// serial receive
	output tx,				// serial transmit
	output [7:0] debug
);
	localparam UART_DIV = UART_CLK / (BAUD_RATE*8);

	// reg
	reg		receiveFlag = 1'b0;
	reg	load;
	reg [7:0] dout;

	// wire
	wire	bytercvd;
	wire	txbusy;
	wire [7:0] q;

	// assign
	wire transmit =  cs & (addr == 2'b00) & we;
	wire receive =  cs & (addr == 2'b00) & !we;

	wire [7:0] status = 
	{
		1'b0,			// bit 7 
		1'b0,			// bit 6 
		1'b0,			// bit 5 
		1'b0,			// bit 4 
		1'b0,			// bit 3 
		1'b0,			// bit 2 
		receiveFlag,	// bit 1 
		txbusy			// bit 0 
	};
	
	always @(posedge clk)
		case(addr)
			2'b00: dout <= q;
			2'b01: dout <= status;
			2'b10: dout <= 8'h00;
			2'b11: dout <= 8'h00;
		endcase

	// reset receive flag
	always @(posedge clk)
	begin
		if(receive)
			receiveFlag <= 1'b0;
		if(bytercvd)
			receiveFlag <= 1'b1;

	end

	// auto transmit
	always @(posedge clk)
		if(transmit)
			load <= 1'b1;
		else
			load <= 1'b0;

	//clock cycle
	wire bitxce;
	reg [log2(UART_DIV)-1:0] bitxcecnt;
	always @(posedge clk)
		bitxcecnt <= (bitxcecnt == UART_DIV-1 ? 0 : bitxcecnt+1);
	assign bitxce = (bitxcecnt == 0 ? 1 : 0); // + LUTs

	// Assumtions: 12M clock. 115200 bps. 8N1 format.
	// 12000000/(115200∗8) = 13.02
	/*reg [4:0]  bitxcecnt;
	always @(posedge clk)
		bitxcecnt <= bitxcecnt[4] ? 5'd4 : bitxcecnt+5'd1;
	assign bitxce = bitxcecnt[4];*/

	// uart unit
	uart uuart(
		.clk			(clk),
		.txpin			(tx),
		.rxpin			(rx),
		// tx
		.txbusy			(txbusy), // Status of transmit. When high do not load
		.load			(load), // Load transmit buffer
		.d				(din),
		// rx
		.bytercvd		(bytercvd), // Status receive. True 1 clock cycle only
		.q				(q),
		// debug
		.bitxce			(bitxce) // High 1 clock cycle 8 or 16 times per bit
		//.rxst			(rxst[1:0]),
	);
	
	//** TASKS / FUNCTIONS **************************************** 
	function integer log2(input integer M);
		integer i;
	begin
		log2 = 1;
		for (i = 0; 2**i <= M; i = i + 1)
			log2 = i + 1;
	end endfunction

endmodule
