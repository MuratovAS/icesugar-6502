// spi_wrapper.v - strippped-down version of MC6850 ACIA wrapped around FOSS UART
// 03-02-19 E. Brombaugh

`include "src/ext/simplespi.v"

module spi_wrapper#(
	parameter CPOL = 1'b0,
	parameter CPHA = 1'b0,
	parameter SPI_DIV = 2
)(
    input clk,
    input rst,
    input cs,
    input we,
    input[1:0] addr,
    input[7:0] din,
    output[7:0] dout,
    output sclk,
	output mosi,
	input  miso,
    output spi_cs
);
    `define COM_START  command[0]
    `define COM_FINISH command[1]

	reg [7:0] dout;

	reg[7:0] command = 8'h0;
	reg[7:0] data_wr = 8'h0;
    reg      err;

	wire[7:0] data_rd;
	wire req_next;

	wire write_sel =  cs & we;
	wire read_sel =  cs & !we;

	wire[7:0] status = 
	{
		req_next,		// bit 7 
		err,			// bit 6 
		1'b0,			// bit 5 
		1'b0,			// bit 4 
		1'b0,			// bit 3 
		1'b0,			// bit 2 
		`COM_FINISH,		// bit 1
		`COM_START		// bit 0
	};

    always @(posedge clk)
    begin
		if (read_sel) begin
			case(addr)
				2'h0 : dout <= data_rd;
				2'h1 : dout <= status;
				default : dout = 8'h00;
			endcase
		end

        if (write_sel) begin
            case(addr)
				2'h0 : data_wr <= din;
				2'h1 : command <= din;
            endcase
			err <= ~status[0];
        end

		if( `COM_START == 1'b1 ) begin
			`COM_START <= 1'b0;
		end

		if(rst)
			`COM_FINISH <= 1'b0;
    end

	//clock cycle
	wire bitxce;
	reg [log2(SPI_DIV)-1:0] bitxcecnt;
	always @(posedge clk)
		bitxcecnt <= (bitxcecnt == SPI_DIV-1 ? 0 : bitxcecnt+1);
	assign bitxce = (bitxcecnt == 0 ? 1 : 0); // + LUTs

	simplespi master (
		.clk			(clk),
		.clk_spi_en		(bitxce),
		.reset			(rst),

		.req_next		(req_next),

		.start			(`COM_START),
		.finish			(`COM_FINISH),

		.CPOL			(CPOL),
		.CPHA			(CPHA),

		.data_write		(data_wr),
		.data_read		(data_rd),

		.sclk			(sclk),
		.mosi			(mosi),
		.miso			(miso),
		.cs				(spi_cs)
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
