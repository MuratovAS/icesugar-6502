//
// icesugar-z80 for TV80 SoC for Lattice iCE40
//
// Copyright (c) 2022 Aleksej Muratov
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

module wdt (
    input clk,
    input rst,
    input cs,
    input we,
    input[1:0] addr,
    input[7:0] din,
    //output[7:0] dout,
    input pause_n,
    output reset
);
    reg reset;
    //reg [7:0] dout;

    reg[7:0] comparator;
    reg[7:0] divider;
    reg[7:0] counter;
    reg[7:0] counter_divider;

    wire write_sel = cs & we;

    /*always @(*)
	begin
		case(addr)
			2'b00 : dout <= comparator;
			2'b01 : dout <= divider;
			2'b10 : dout <= counter;
			default : dout <= 8'h00;
		endcase
	end*/

    always @(posedge clk)
    begin
        if (write_sel) begin
            case(addr)
                2'b00 : comparator <= din;
                2'b01 : divider <= din;
                2'b10 : counter <= din;
            endcase
        end
        else
        begin
            if (pause_n && comparator != 1'b0)
            begin
                if (counter_divider < divider)
                    counter_divider <= counter_divider + 1'b1;
                else
                begin
                    counter_divider <= 8'b1;
                    counter <= counter + 1'b1;
                    if (counter >= comparator)
                    begin
                        reset <= 1'b1;
                        counter <= 8'h0;
                        comparator <= 8'h0;
                    end
                end
            end
        end
        if (rst)
        begin
            reset <= 1'b0;
            counter  <= 8'b0;
            comparator <= 8'h0;
            counter_divider  <= 8'b1;
        end
    end
endmodule
