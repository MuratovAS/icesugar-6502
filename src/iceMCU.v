`include "src/6502/cpu.v"
`include "src/memspram.v"
`include "src/membram.v"
`include "src/uart_wrapper.v"

module iceMCU#(
	parameter RAM_TYPE = 0,
	parameter RAM_WIDTH = 15,
	parameter ROM_WIDTH = 13,
	parameter ROM_LOC = 16'hE000
)(
    input clk,
	output [7:0] gpio_o,
	input [7:0] gpio_i,
	input RX,				// serial RX
	output TX,				// serial TX
	output [7:0] debug
);
	// param
	localparam ROM_SIZE = (1 << ROM_WIDTH);
	localparam RAM_SIZE = (1 << RAM_WIDTH);

	// reg
	reg [7:0] gpio_o;
	reg sys_reset = 1'b1;

	// wire
	wire reset;

	// assign
	assign reset = sys_reset;
	
	// init
	always @(posedge clk) begin
		if( sys_reset == 1'b1 ) 
		begin
			sys_reset	<= 1'b0;
		end
	end

    // The 6502
    wire [15:0] CPU_AB;
    reg [7:0] CPU_DI;
    wire [7:0] CPU_DO;
    wire CPU_WE, CPU_IRQ;
    cpu ucpu(
        .clk(clk),
        .reset(reset),
        .AB(CPU_AB),
        .DI(CPU_DI),
        .DO(CPU_DO),
        .WE(CPU_WE),
        .IRQ(1'b0),
        .NMI(1'b0),
        .RDY(1'b1)
    );
    
	// address decode
	wire ram_sel = (CPU_AB < RAM_SIZE) ? 1 : 0;
	wire gpio_sel = (CPU_AB[15:12] == 4'h8) && (CPU_AB[11:4] == 8'h00) ? 1 : 0;
	wire uart_sel = (CPU_AB[15:12] == 4'h8) && (CPU_AB[11:4] == 8'h01) ? 1 : 0;
	wire rom_sel = (CPU_AB >= ROM_LOC) & (CPU_AB < (ROM_LOC+ROM_SIZE)) ? 1 : 0;
	
	// data mux
	reg [3:0] mux_sel;
	always @(posedge clk)
		mux_sel <= {rom_sel,uart_sel,gpio_sel,ram_sel};
	always @(*)
		casez(mux_sel)
			4'b0001: CPU_DI = ram_do;
			4'b001z: CPU_DI = gpio_do;
			4'b01zz: CPU_DI = uart_do;
			4'b1zzz: CPU_DI = rom_do;
			default: CPU_DI = rom_do;
		endcase
		

    wire [7:0] ram_do;
	//generate
    if(RAM_TYPE == 0) begin
		// FPGA BRAM
		membram #(RAM_WIDTH) uram
		(
			.clk(clk),
			.sel(ram_sel),
			.we(CPU_WE),
			.addr(CPU_AB[RAM_WIDTH-1:0]),
			.din(CPU_DO),
			.dout(ram_do)
		);
	end else if(RAM_TYPE == 1) begin
		// UltraPlus SPRAM
		memspram #(RAM_WIDTH) uram(
			.clk(clk),
			.sel(ram_sel),
			.we(CPU_WE),
			.addr(CPU_AB[RAM_WIDTH-1:0]),
			.din(CPU_DO),
			.dout(ram_do)
		);
    end
	//endgenerate
	
    wire [7:0] rom_do;
	membram #(ROM_WIDTH, `__def_fw_img, 1) urom
	(
			.clk(clk),
			.sel(rom_sel),
			.we(CPU_WE),
			.addr(CPU_AB[ROM_WIDTH-1:0]),
			.din(CPU_DO),
			.dout(rom_do)
	);

	// GPIO @ page 10-1f
	reg [7:0] gpio_do;
	always @(posedge clk)
		if((CPU_WE == 1'b1) && (gpio_sel == 1'b1))
			gpio_o <= CPU_DO;
	always @(posedge clk)
		gpio_do <= gpio_o;
		//gpio_do <= gpio_i;
	
	wire [7:0] uart_do;
	uart_wrapper uuart(
		.clk(clk),				// system clock
		.rst(reset),			// system reset
		.cs(uart_sel),			// chip select
		.we(CPU_WE),			// write enable
		.addr(CPU_AB[1:0]),		// addr bus input
		.din(CPU_DO),			// data bus input
		.dout(uart_do),			// data bus output
		.rx(RX),				// serial receive
		.tx(TX),				// serial transmit
		.debug(debug)
	);
	defparam uuart.UART_CLK = 12000000;
	defparam uuart.BAUD_RATE = 115200;

endmodule
