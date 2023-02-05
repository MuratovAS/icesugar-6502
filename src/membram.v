// membram.v - 32k byte inferred RAM
// 03-11-18 E. Brombaugh

module membram #(
    parameter ADDR_WIDTH = 12,
	parameter MEM_HEX = "",
	parameter MEM_INIT = 0
) (
    input clk,
    output[7:0] dout,
    input[7:0] din,
    input sel,
    input we,
    input[ADDR_WIDTH-1:0] addr
);
    reg [7:0] dout;
    reg [7:0] mem_8 [0:(1 << ADDR_WIDTH)-1];

    initial begin
        if( MEM_INIT > 0 ) begin
            $readmemh(MEM_HEX, mem_8, 0, (1 << ADDR_WIDTH)-1);
        end
    end

    always @(posedge clk)
    begin
        if (sel & we) begin
            mem_8[addr] <= din;
        end
    end

    always @(posedge clk)
        dout <= mem_8[addr];

	// ROM @ pages f0,f1...
    /*reg [7:0] rom_mem[4095:0];
	reg [7:0] rom_do;
	initial
        $readmemh("build/icesugar-6502_fw.hex",rom_mem);
	always @(posedge clk)
		rom_do <= rom_mem[CPU_AB[11:0]];*/
        ///////////////////////////////////////////////////
	// integer i;
    // reg [7:0] memory[0:32767];
	
	// // clear RAM to avoid simulation errors
	// initial
	// 	for (i = 0; i < 32768; i = i +1)
	// 		memory[i] <= 0;
    
    // // synchronous write
    // always @(posedge clk)
    //     if(sel & we)
    //         memory[addr] <= din;
    
    // // synchronous read
    // always @(posedge clk)
    //     dout <= memory[addr];

endmodule
